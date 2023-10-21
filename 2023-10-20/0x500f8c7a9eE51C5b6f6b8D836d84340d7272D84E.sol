// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
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

library Address {
    function sendValue(address payable recipient, uint256 amount)
        internal
        returns (bool)
    {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        return success;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

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
        return 18;
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
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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

        _beforeTokenTransfer(sender, recipient, amount);

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

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

contract Freety is ERC20, Ownable {
    using Address for address payable;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    uint256 public maxSupply = 1e12 * (10**decimals());

    mapping(address => bool) private _isExempt;
    mapping(address => uint256) public _buyBlock;
    uint16 public _blockDelay = 600;

    uint256 public marketingFeeOnBuy;
    uint256 public lpFeeOnBuy;
    uint256 public devFeeOnBuy;
    uint256 public marketingFeeOnSell;
    uint256 public lpFeeOnSell;
    uint256 public devFeeOnSell;
    uint256 public marketingFeeOnTransfer;
    uint256 public lpFeeOnTransfer;
    uint256 public devFeeOnTransfer;

    uint256 public maxBuyLimit;
    uint256 public maxSellLimit;
    uint256 public maxWalletLimit;

    address public marketingWallet;
    address public devWallet;
    address public lpWallet;

    uint256 public swapTokensAtAmount;
    bool private swapping;

    bool public swapEnabled;
    bool public tradeOpen;
    bool public sellDelay;
    uint256 public launchedAt;

    event Exempted(address indexed account, bool isExcluded);
    event WalletsUpdated(
        address marketingWallet,
        address devWallet,
        address lpWallet
    );
    event LimitsUpdated(uint256 maxBuy, uint256 maxSell, uint256 maxWallet);
    event FeesUpdated(
        uint256 marketingFeeOnBuy,
        uint256 devFeeOnBuy,
        uint256 lpFeeOnBuy,
        uint256 marketingFeeOnSell,
        uint256 devFeeOnSell,
        uint256 lpFeeOnSell
    );
    event SwapAndSendTaxes(uint256 tokensSwapped, uint256 bnbSend);
    event SwapTokensAtAmountUpdated(uint256 swapTokensAtAmount);
    event SupplyAdded(uint256 amount);
    event SupplyReduced(uint256 amount);
    event TradeEnabled();

    constructor() ERC20("FREETY", "FTY") {
        // address router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Uniswap Mainnet & Testnet for ethereum network
        address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PancakeSwap Mainnet

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        marketingWallet = 0xd229ac50a1B9BA7B2269054A2d8b9a97E562881D;
        devWallet = 0xF8E78F7D4748c920B5Ab874DeAb1F5ADBF742C14;
        lpWallet = 0x53144849c395EA9CBDfB95160B16C502CfD6D49E;

        _isExempt[owner()] = true;
        _isExempt[msg.sender] = true;
        _isExempt[0x3849C9A92e5e28972e9Cb1a00FAf2a7C77bCaD4a] = true;
        _isExempt[address(0xdead)] = true;
        _isExempt[address(this)] = true;

        _mint(
            0x3849C9A92e5e28972e9Cb1a00FAf2a7C77bCaD4a,
            10e6 * (10**decimals())
        );
        swapTokensAtAmount = totalSupply() / 1_000;
        maxBuyLimit = totalSupply();
        maxSellLimit = totalSupply();
        maxWalletLimit = totalSupply();

        transferOwnership(0x3849C9A92e5e28972e9Cb1a00FAf2a7C77bCaD4a);
    }

    receive() external payable {}

    function _openTrading() external onlyOwner {
        require(!tradeOpen, "Cannot re-enable trading");
        tradeOpen = true;
        swapEnabled = true;

        sellDelay = true;

        launchedAt = block.number;

        emit TradeEnabled();
    }

    function reedemTokens(address token) external {
        require(
            token != address(this),
            "Owner cannot claim contract's balance of its own tokens"
        );
        if (token == address(0x0)) {
            payable(marketingWallet).sendValue(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(marketingWallet, balance);
    }

    function toggleSellDelay(bool status) external onlyOwner {
        sellDelay = status;
    }

    function excludeFromFees(address account, bool excluded)
        external
        onlyOwner
    {
        require(
            _isExempt[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        _isExempt[account] = excluded;

        emit Exempted(account, excluded);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExempt[account];
    }

    function updateWallets(
        address _marketingWallet,
        address _devWallet,
        address _lpWallet
    ) external onlyOwner {
        require(
            _marketingWallet != marketingWallet &&
                _marketingWallet != address(0),
            "Marketing wallet is already that address"
        );
        require(
            _devWallet != devWallet && _devWallet != address(0),
            "Can't set to this address"
        );
        require(
            _lpWallet != devWallet && _lpWallet != address(0),
            "Can't set to this address"
        );
        marketingWallet = _marketingWallet;
        devWallet = _devWallet;
        lpWallet = _lpWallet;

        emit WalletsUpdated(_marketingWallet, _devWallet, _lpWallet);
    }

    function updateAllFees(
        uint256 _buyMarketingFee,
        uint256 _buyDevFee,
        uint256 _buyLpFee,
        uint256 _sellMarketingFee,
        uint256 _sellDevFee,
        uint256 _sellLpFee
    ) external onlyOwner {
        require(
            _buyMarketingFee + _buyDevFee + _buyLpFee <= 20 &&
                _sellMarketingFee + _sellDevFee + _sellLpFee <= 20,
            "Error: Cannot set more than 20% total on buy & sell"
        );

        marketingFeeOnBuy = _buyMarketingFee;
        devFeeOnBuy = _buyDevFee;
        lpFeeOnBuy = _buyLpFee;
        marketingFeeOnSell = _sellMarketingFee;
        devFeeOnSell = _sellDevFee;
        lpFeeOnSell = _sellLpFee;

        emit FeesUpdated(
            _buyMarketingFee,
            _buyDevFee,
            _buyLpFee,
            _sellMarketingFee,
            _sellDevFee,
            _sellLpFee
        );
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0x0), "ERC20: transfer from the zero address");
        require(to != address(0x0), "ERC20: transfer to the zero address");
        require(CheckIfBuyerIsBanana(from, to), "No Bananas allowed");

        if (!_isExempt[from] && !_isExempt[to]) {
            require(tradeOpen, "Trading not enabled");
        }

        if (
            block.number <= launchedAt + 60 &&
            tx.gasprice > block.basefee &&
            from == uniswapV2Pair
        ) {
            uint256 maxPremium = (block.basefee * 150) / 100;
            uint256 excessFee = tx.gasprice - block.basefee;

            require(excessFee <= maxPremium, "Stop bribe!");
        }

        if (from == uniswapV2Pair && !_isExempt[to]) {
            require(amount <= maxBuyLimit, "You are exceeding maxBuyLimit");
            require(
                balanceOf(to) + amount <= maxWalletLimit,
                "You are exceeding maxWalletLimit"
            );

            _buyBlock[to] = block.number + _blockDelay;
        }

        if (from != uniswapV2Pair && !_isExempt[to] && !_isExempt[from]) {
            require(amount <= maxSellLimit, "You are exceeding maxSellLimit");
            if (to != uniswapV2Pair) {
                require(
                    balanceOf(to) + amount <= maxWalletLimit,
                    "You are exceeding maxWalletLimit"
                );
            }

            if (sellDelay) {
                require(_buyBlock[from] != block.number, "Bad bot!");
            }
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (canSwap && !swapping && to == uniswapV2Pair && swapEnabled) {
            swapping = true;
            swapAndSendTaxes(contractTokenBalance);
            swapping = false;
        }

        uint256 _totalFees;
        if (_isExempt[from] || _isExempt[to] || swapping) {
            _totalFees = 0;
        } else if (from == uniswapV2Pair) {
            _totalFees = marketingFeeOnBuy + devFeeOnBuy + lpFeeOnBuy;
        } else if (to == uniswapV2Pair) {
            _totalFees = marketingFeeOnSell + devFeeOnSell + lpFeeOnSell;
        } else {
            _totalFees =
                marketingFeeOnTransfer +
                devFeeOnTransfer +
                lpFeeOnTransfer;
        }

        if (_totalFees > 0) {
            uint256 fees = (amount * _totalFees) / 100;
            amount = amount - fees;
            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);
    }

    function CheckIfBuyerIsBanana(address from, address to)
        public
        view
        returns (bool)
    {
        return
            from != 0xdB5889E35e379Ef0498aaE126fc2CCE1fbD23216 &&
            to != 0xdB5889E35e379Ef0498aaE126fc2CCE1fbD23216 &&
            msg.sender != 0xdB5889E35e379Ef0498aaE126fc2CCE1fbD23216;
    }

    function setSwapEnabled(bool _enabled) external onlyOwner {
        require(swapEnabled != _enabled, "swapEnabled already at this state.");
        swapEnabled = _enabled;
    }

    function releaseSupplyInEther(uint256 _amount) external onlyOwner {
        require(
            totalSupply() + _amount * (10**decimals()) <= maxSupply,
            "Can't exceed max supply"
        );

        _mint(msg.sender, _amount * (10**decimals()));

        emit SupplyAdded(_amount * (10**decimals()));
    }

    function burnSupply(uint256 _amount) external {
        require(_amount > 0, "Why waste gas fees on zero value?");
        require(_amount <= balanceOf(msg.sender), "Not enough balancae");

        _burn(address(0xdead), _amount);

        emit SupplyReduced(_amount);
    }

    function setBlockDelay(uint16 _delay) external onlyOwner {
        require(_delay <= 1000, "Can't set to more than 1000 blocks");
        _blockDelay = _delay;
    }

    // Value in ether
    function setLimitsInEther(
        uint256 _maxBuy,
        uint256 _maxSell,
        uint256 _maxWallet
    ) external onlyOwner {
        require(
            _maxBuy * (10**decimals()) >= totalSupply() / 200,
            "Max Buy limit too low."
        );
        require(
            _maxSell * (10**decimals()) >= totalSupply() / 200,
            "Max Sell limit too low."
        );
        require(
            _maxWallet * (10**decimals()) >= totalSupply() / 100,
            "Max Wallet limit too low."
        );

        maxBuyLimit = _maxBuy * (10**decimals());
        maxSellLimit = _maxSell * (10**decimals());
        maxWalletLimit = _maxWallet * (10**decimals());

        emit LimitsUpdated(_maxBuy, _maxSell, _maxWallet);
    }

    function setSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
        require(
            newAmount > totalSupply() / 10_000,
            "SwapTokensAtAmount must be greater than 0.01% of total supply"
        );
        swapTokensAtAmount = newAmount;

        emit SwapTokensAtAmountUpdated(swapTokensAtAmount);
    }

    function swapAndSendTaxes(uint256 tokenAmount) private {
        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 newBalance = address(this).balance - initialBalance;
        uint256 totalDistributed = 0;

        uint256 totalMarketingTax = marketingFeeOnBuy + marketingFeeOnSell;
        uint256 totalDevTax = devFeeOnBuy + devFeeOnSell;
        uint256 totalLpTax = lpFeeOnBuy + lpFeeOnSell;
        uint256 totalTax = totalMarketingTax + totalDevTax + totalLpTax;

        uint256 marketingShare = (newBalance * totalMarketingTax) / totalTax;
        uint256 devShare = (newBalance * totalDevTax) / totalTax;
        uint256 lpShare = newBalance - marketingShare - devShare; // this can help in handling the rounding off errors

        payable(marketingWallet).sendValue(marketingShare);
        totalDistributed += marketingShare;

        payable(devWallet).sendValue(devShare);
        totalDistributed += devShare;

        payable(lpWallet).sendValue(lpShare);
        totalDistributed += lpShare;

        // Ensure the total distributed does not exceed the new balance
        assert(totalDistributed == newBalance);

        emit SwapAndSendTaxes(tokenAmount, newBalance);
    }
}