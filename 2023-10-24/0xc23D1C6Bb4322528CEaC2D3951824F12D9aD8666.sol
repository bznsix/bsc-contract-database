//SPDX-License-Identifier: MIT

pragma solidity =0.8.19;

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface BEP20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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

interface IDEXRouter {
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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;

    function claimDividend(address shareholder) external;

    function getUnpaidEarnings(address shareholder)
        external
        view
        returns (uint256);
}

interface IDividendDistributorFactory {
    function createDistribuitor(address router) external returns (address);
}

contract TokenDividend {
    IDividendDistributorFactory public distributorFactory =
        block.chainid == 56
            ? distributorFactory = IDividendDistributorFactory(
                0xEc7b409F208Fce08770014ecD2f2bc907A103d2f
            )
            : block.chainid == 97
            ? distributorFactory = IDividendDistributorFactory(
                0xcFc9c9305a774E256B15e5d6148309520bAc0593
            )
            : (block.chainid == 1 || block.chainid == 5)
            ? distributorFactory = IDividendDistributorFactory(
                0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
            )
            : distributorFactory = IDividendDistributorFactory(
            0xEc7b409F208Fce08770014ecD2f2bc907A103d2f
        );
    IDividendDistributor public distributor;
    IDEXRouter public router =
        block.chainid == 56
            ? router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E)
            : block.chainid == 97
            ? router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1)
            : (block.chainid == 1 || block.chainid == 5)
            ? router = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)
            : router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public WBNB = router.WETH();

    string _name = "ZeldaInu";
    string _symbol = "ZELDA";
    uint8 _decimals = 18;
    uint256 _totalSupply = 420000000000000000 * 10**_decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => bool) public pair;
    mapping(address => bool) public isDividendExempt;

    uint256 public buyTax = 500;
    uint256 public sellTax = 1200;

    //BUY FEES
    uint256 public liquidityFee = 0;
    uint256 public marketingFee = 0;
    uint256 public reflectionFee = 0;
    uint256 public burnFee = 500;

    //SELL FEES
    uint256 public sellLiquidityFee = 100;
    uint256 public sellMarketingFee = 600;
    uint256 public sellReflectionFee = 500;
    uint256 public sellBurnFee = 0;

    uint256 public feeDenominator = 10000;
    uint256 public distributorGas = 300000;
    uint256 public txbnbGas = 50000;
    uint256 public distributorBuyGas = 400000;
    uint256 public LiquidifyGas = 500000;
    uint256 public swapThreshold = 10 * (10**_decimals);

    address public marketingFeeReceiver =
        0x5A90a46d85Fa829E03aec440970f03FA3A28A6d0;
    address public buytokensReceiver =
        0x5A90a46d85Fa829E03aec440970f03FA3A28A6d0;

    bool public swapEnabled = true;
    bool inSwap;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    address private _owner;

    constructor() payable {
        _owner = msg.sender;
        _allowances[address(this)][address(router)] =
            100000000 *
            (10**50) *
            100;
        address _pair = IDEXFactory(router.factory()).createPair(
            WBNB,
            address(this)
        );
        pair[_pair] = true;
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        isDividendExempt[_pair] = true;
        isDividendExempt[address(this)] = true;
        _balances[msg.sender] = _totalSupply;
        distributor = IDividendDistributor(
            distributorFactory.createDistribuitor(address(router))
        );

        emit OwnershipTransferred(address(0), msg.sender);
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        require(
            _allowances[sender][msg.sender] >= amount,
            "Insufficient Allowance"
        );
        _allowances[sender][msg.sender] =
            _allowances[sender][msg.sender] -
            amount;
        return _transferFrom(sender, recipient, amount);
    }

    function setPair(address _pair, bool io) public onlyOwner {
        pair[_pair] = io;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setDividendExempt(address account, bool b) public onlyOwner {
        isDividendExempt[account] = b;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(amount != 0);
        require(amount <= _balances[account]);
        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    function _burnIN(address account, uint256 amount) internal {
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            !pair[msg.sender] &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }

    function setmarketingFeeReceivers(address _marketingFeeReceiver)
        external
        onlyOwner
    {
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setbuytokensReceiver(address _buytokensReceiver)
        external
        onlyOwner
    {
        buytokensReceiver = _buytokensReceiver;
    }

    function setSwapBackSettings(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
    }

    function value(uint256 amount, uint256 percent)
        public
        view
        returns (uint256)
    {
        return percent == 0 ? 0 : (amount * percent) / feeDenominator;
    }

    function _isSell(bool a) internal view returns (uint256) {
        if (a) {
            return sellTax;
        } else {
            return buyTax;
        }
    }

    function BURNFEE(bool a) internal view returns (uint256) {
        if (a) {
            return sellBurnFee;
        } else {
            return burnFee;
        }
    }

    function MKTFEE(bool a) internal view returns (uint256) {
        if (a) {
            return sellMarketingFee;
        } else {
            return marketingFee;
        }
    }

    function LIQUIFYFEE(bool a) internal view returns (uint256) {
        if (a) {
            return sellLiquidityFee;
        } else {
            return liquidityFee;
        }
    }

    function REFFEE(bool a) internal view returns (uint256) {
        if (a) {
            return sellReflectionFee;
        } else {
            return reflectionFee;
        }
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            _basicTransfer(sender, recipient, amount);
            return true;
        } else {
            uint256 liquidifyFeeAmount = value(
                amount,
                LIQUIFYFEE(pair[recipient])
            );
            uint256 marketingFeeAmount = value(amount, MKTFEE(pair[recipient]));
            uint256 refFeeAmount = value(amount, REFFEE(pair[recipient]));
            uint256 burnFeeAmount = value(amount, BURNFEE(pair[recipient]));

            uint256 FeeAmount = liquidifyFeeAmount +
                marketingFeeAmount +
                refFeeAmount;

            _txTransfer(sender, address(this), FeeAmount);

            swapThreshold = balanceOf(address(this));
            if (shouldSwapBack()) {
                swapBack(marketingFeeAmount, liquidifyFeeAmount, refFeeAmount);
            } else {
                _balances[address(this)] = _balances[address(this)] - FeeAmount;
                _txTransfer(address(this), buytokensReceiver, FeeAmount);

                swapThreshold = balanceOf(address(this));
            }
            _burnIN(sender, burnFeeAmount);
            uint256 feeAmount = value(amount, _isSell(pair[recipient]));
            uint256 amountWithFee = amount - feeAmount;

            _balances[sender] = _balances[sender] - amount;
            _balances[recipient] = _balances[recipient] + amountWithFee;

            if (!isDividendExempt[sender]) {
                try distributor.setShare(sender, balanceOf(sender)) {} catch {}
            }

            if (!isDividendExempt[recipient]) {
                try
                    distributor.setShare(recipient, balanceOf(recipient))
                {} catch {}
            }
            try distributor.process(distributorGas) {} catch {}
            emit Transfer(sender, recipient, amountWithFee);
            return true;
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(_balances[sender] >= amount, "Insufficient Balance");
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _txTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function getamount(uint256 amount, address[] memory path)
        internal
        view
        returns (uint256)
    {
        return router.getAmountsOut(amount, path)[1];
    }

    function swapBack(
        uint256 marketing,
        uint256 liquidity,
        uint256 reflection
    ) internal swapping {
        uint256 a = marketing + liquidity + reflection;
        if (a <= swapThreshold) {} else {
            a = swapThreshold;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 amountBNBLiquidity = liquidity > 0
            ? getamount(liquidity / 2, path)
            : 0;
        uint256 amountBNBMarketing = marketing > 0
            ? getamount(marketing, path)
            : 0;
        uint256 amountBNBReflection = reflection > 0
            ? getamount(reflection, path)
            : 0;

        uint256 amountToLiquidify = liquidity > 0 ? (liquidity / 2) : 0;

        uint256 amountToSwap = amountToLiquidify > 0
            ? a - amountToLiquidify
            : a;

        swapThreshold = balanceOf(address(this));

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        bool success;
        if (amountBNBMarketing > 0) {
            (success, ) = payable(marketingFeeReceiver).call{
                value: amountBNBMarketing,
                gas: txbnbGas
            }("");
            // payable(marketingFeeReceiver).transfer(amountBNBMarketing);
        }

        if (amountBNBReflection > 0) {
            try
                distributor.deposit{
                    value: amountBNBReflection,
                    gas: distributorBuyGas
                }()
            {} catch {}
        }

        if (amountToLiquidify > 0) {
            router.addLiquidityETH{
                value: amountToLiquidify <= address(this).balance
                    ? amountBNBLiquidity
                    : address(this).balance,
                gas: LiquidifyGas
            }(
                address(this),
                amountToLiquidify,
                0,
                0,
                address(this),
                block.timestamp
            );
        }
    }

    function manualSend() external onlyOwner {
        payable(marketingFeeReceiver).transfer(address(this).balance);
        _basicTransfer(
            address(this),
            marketingFeeReceiver,
            balanceOf(address(this))
        );
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function claimDividend() external {
        distributor.claimDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        return distributor.getUnpaidEarnings(shareholder);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 3000000);
        distributorGas = gas;
    }

    function setTXBNBgas(uint256 gas) external onlyOwner {
        require(gas < 100000);
        txbnbGas = gas;
    }

    function setDistribuitorBuyGas(uint256 gas) external onlyOwner {
        require(gas < 1000000);
        distributorBuyGas = gas;
    }

    function setLiquidifyGas(uint256 gas) external onlyOwner {
        require(gas < 1000000);
        LiquidifyGas = gas;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}