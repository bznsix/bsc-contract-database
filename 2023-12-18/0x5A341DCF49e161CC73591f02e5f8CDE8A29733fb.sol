//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./libs/IBEP20.sol";
import "./libs/Auth.sol";
import "./libs/SafeMath.sol";
import "./libs/IDEX.sol";
import "./libs/IProviderPair.sol";
import "./libs/ICalculator.sol";
import "./DividendDistributor.sol";

interface IReflectoRewards {
    function _updateRewardsPerToken() external;

    function _updateUserRewards(address user) external;
}

contract Reflecto is IBEP20, Auth {
    using SafeMath for uint256;

    struct Swap {
        uint256 liquidityFee;
        uint256 reflectionFee;
        uint256 marketingFee;
        uint256 gasWalletFee;
        uint256 totalFee;
        uint256 swapThreshold;
    }

    struct Processing {
        bool onSell;
        bool onBuy;
        bool onTransfer;
    }

    Processing public whenProcess;
    uint256 public constant MASK = type(uint128).max;
    address BUSD;
    address Crypter;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Reflecto";
    string constant _symbol = "RTO";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 1_000_000_000_000_000 * (10**_decimals);

    mapping(address => uint256) _balances;
    mapping(address => uint256) public nonces;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    mapping(address => bool) isDividendExempt;

    IDEXRouter[] public routers;
    mapping(address => bool) public isBNBRouter;
    uint256 routerIndex = 0;
    IDEXRouter public defaultRouter;
    bool public isDefaultForSwap = false;

    address public calculator;

    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
    address public gasWalletFeeReceiver;

    uint256 targetLiquidity = 25;
    uint256 targetLiquidityDenominator = 100;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;

    uint256 buybackMultiplierNumerator = 200;
    uint256 buybackMultiplierDenominator = 100;
    uint256 buybackMultiplierTriggeredAt;
    uint256 buybackMultiplierLength = 30 minutes;

    bool public autoBuybackEnabled = false;
    mapping(address => bool) buyBacker;
    mapping(address => bool) public pairs;
    uint256 autoBuybackCap;
    uint256 autoBuybackAccumulator;
    uint256 autoBuybackAmount;
    uint256 autoBuybackBlockPeriod = 1 minutes;
    uint256 autoBuybackBlockLast;
    bool public isRoundRobinBuyback = false;

    IReflectoRewards public reflectoRewards;

    bool isCancelingEnabled = true;
    uint256 burnDivider = 0;
    bool isBuyBackEnabled = true;
    uint256 buyBackDivider = 0;

    bool isSentToPoolEnabled = true;

    uint256 public minimumStakingLimit = 100000000000000000000;

    DividendDistributor distributor;
    // address public distributorAddress;
    uint256 distributorGas = 500000;

    // --- EIP712 niceties ---
    bytes32 public DOMAIN_SEPARATOR;
    // bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address holder,address spender,uint256 nonce,uint256 expiry,bool allowed)");
    bytes32 public constant PERMIT_TYPEHASH =
        0xea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb;

    bool public swapEnabled = true;
    bool public isSwapOnSell = true;

    mapping(address => uint256) public timeOfSell;
    mapping(address => uint256) public amountOfSell;
    uint256 public sellLimit = 100000000000000000000;

    uint256 public maxCancelingAmount = 100000000000000000000;

    uint256 public burnCounter = 0;

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    mapping(address => bool) public isUserMigrated;
    bool public isMigrationEnded;

    constructor() Auth(msg.sender) {
        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        buyBacker[msg.sender] = true;

        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = msg.sender;
        gasWalletFeeReceiver = msg.sender;

        _balances[msg.sender] = _totalSupply;

        whenProcess.onBuy = true;
        whenProcess.onSell = true;
        whenProcess.onTransfer = true;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(_name)),
                keccak256(bytes(version())),
                block.chainid,
                address(this)
            )
        );

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setProcessing(
        bool _onBuy,
        bool _onSell,
        bool _onTransfer
    ) external authorized {
        whenProcess.onBuy = _onBuy;
        whenProcess.onSell = _onSell;
        whenProcess.onTransfer = _onTransfer;
    }

    function endMigration() external authorized {
        isMigrationEnded = true;
    }

    function setAutoStakingContract(address reflectoRewardsContract)
        external
        authorized
    {
        isDividendExempt[reflectoRewardsContract] = true;
        isFeeExempt[reflectoRewardsContract] = true;
        reflectoRewards = IReflectoRewards(reflectoRewardsContract);
    }

    function setSellCancelingEnabled(bool _isEnabled) external authorized {
        isCancelingEnabled = _isEnabled;
    }

    function setMaxSellCancelingAmount(uint256 _amount) external authorized {
        maxCancelingAmount = _amount;
    }

    function setEnableRoundRobinBuyback(bool _isEnabled) external authorized {
        isRoundRobinBuyback = _isEnabled;
    }

    function setPoolSendEnabled(bool _isEnabled) external authorized {
        isSentToPoolEnabled = _isEnabled;
    }

    function addPair(address pairAddress) external authorized {
        pairs[pairAddress] = true;
        isDividendExempt[pairAddress] = true;
    }

    function deletePair(address pairAddress) external authorized {
        pairs[pairAddress] = false;
        isDividendExempt[pairAddress] = false;
    }

    function setDefaultRouter(address router, bool isBNB) external authorized {
        defaultRouter = IDEXRouter(router);
        isBNBRouter[router] = isBNB;
        _allowances[address(this)][router] = _totalSupply;
    }

    function setDefaultRouterFromSwapBack(bool isEnabled) external authorized {
        isDefaultForSwap = isEnabled;
    }

    function addRouter(address router, bool isBNB) external authorized {
        IDEXRouter routerNew = IDEXRouter(router);
        _allowances[address(this)][router] = _totalSupply;
        isBNBRouter[router] = isBNB;
        routers.push(routerNew);
        routerIndex = 0;
    }

    function removeRouter(uint256 index) external authorized {
        IDEXRouter routerLast = routers[routers.length - 1];
        routers[index] = routerLast;
        routers.pop();
        routerIndex = 0;
    }

    function getRouter() internal view returns (IDEXRouter) {
        if (isDefaultForSwap) {
            return defaultRouter;
        }
        IDEXRouter currentRouter = routers[routerIndex];

        return currentRouter;
    }

    function updateRouterIndex() internal {
        if (routerIndex + 1 > routers.length - 1) {
            routerIndex = 0;
        } else {
            routerIndex = routerIndex + 1;
        }
    }

    function setFeeCalulator(address calc) external authorized {
        calculator = calc;
    }

    function setMinimumStakingLimitAmount(uint256 amount) external authorized {
        minimumStakingLimit = amount;
    }

    /// @dev Setting the version as a function so that it can be overriden
    function version() public pure virtual returns (string memory) {
        return "1";
    }

    function getChainID() external view returns (uint256) {
        return block.chainid;
    }

    receive() external payable {}

    // For testing
    function donate() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    modifier onlyBuybacker() {
        require(buyBacker[msg.sender] == true, "");
        _;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function migrateV1ToV2(address[] memory v1holders)
        external
        authorized
        returns (bool)
    {
        require(isMigrationEnded == false, "Migration completed");

        for (uint256 i = 0; i < v1holders.length; i++) {
            uint256 bHolder = IBEP20(0xaeFCb0411c83B5422Fcf122efEA6D262D2455012)
                .balanceOf(v1holders[i]);
            if (
                bHolder > 0 &&
                bHolder < 20000000000000000000000 &&
                !isUserMigrated[v1holders[i]]
            ) {
                _balances[msg.sender] = _balances[msg.sender].sub(
                    bHolder,
                    "Insufficient Balance"
                );
                _balances[v1holders[i]] = bHolder;
                isUserMigrated[v1holders[i]] = true;
                emit Transfer(msg.sender, v1holders[i], bHolder);
            }
        }
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (
            (isDividendExempt[sender] || isDividendExempt[recipient]) &&
            (!shouldTakeFee(sender) || !shouldTakeFee(recipient))
        ) {
            _basicTransfer(sender, recipient, amount);
            if (!isDividendExempt[sender]) {
                try distributor.setShare(sender, _balances[sender]) {} catch {}
            }
            if (!isDividendExempt[recipient]) {
                try
                    distributor.setShare(recipient, _balances[recipient])
                {} catch {}
            }
            setStakes(sender, recipient);
            if (pairs[recipient]) {
                ICalculator(calculator).registerBuySell(amount, false);
            } else if (pairs[sender]) {
                ICalculator(calculator).registerBuySell(amount, true);
            }
            return true;
        }

        if (shouldAutoBuyback()) {
            autoBuybackBlockLast = block.timestamp;
            algoBB(pairs[recipient], amount);
        }

        Fees memory allFees = ICalculator(calculator).getFees();
        uint256 swapThreshold = ICalculator(calculator).getSwapThreshold();
        if (shouldSwapBack(recipient, swapThreshold)) {
            swapBack(
                Swap(
                    pairs[recipient]
                        ? allFees.sellLiquidityFee
                        : allFees.buyLiquidityFee,
                    pairs[recipient]
                        ? allFees.sellReflectionFee
                        : allFees.buyReflectionFee,
                    pairs[recipient]
                        ? allFees.sellDevelopmentFee
                        : allFees.buyDevelopmentFee,
                    pairs[recipient]
                        ? allFees.sellGasWalletFee
                        : allFees.buyGasWalletFee,
                    pairs[recipient] ? allFees.sellTotal : allFees.buyTotal,
                    swapThreshold
                )
            );
        }

        uint256 amountReceived;
        if (
            ICalculator(calculator).isCustomFeeReceiverOrSender(
                sender,
                recipient
            )
        ) {
            if (!pairs[recipient] && !pairs[sender]) {
                amountReceived = amount;
                if (whenProcess.onTransfer) {
                    try distributor.process(distributorGas) {} catch {}
                }
            } else {
                Fees memory usersFees = ICalculator(calculator).getUserFees(
                    sender,
                    recipient
                );
                amountReceived = !shouldTakeFee(sender) ||
                    !shouldTakeFee(recipient)
                    ? amount
                    : takeFee(
                        sender,
                        amount,
                        pairs[recipient]
                            ? usersFees.sellTotal
                            : usersFees.buyTotal,
                        usersFees.buyFeeDenominator
                    );

                if (pairs[recipient]) {
                    ICalculator(calculator).registerBuySell(amount, false);
                    if (whenProcess.onSell) {
                        try distributor.process(distributorGas) {} catch {}
                    }
                } else if (pairs[sender]) {
                    ICalculator(calculator).registerBuySell(amount, true);
                    if (whenProcess.onBuy) {
                        try distributor.process(distributorGas) {} catch {}
                    }
                }
            }
        } else if (pairs[recipient]) {
            checkTxLimit(sender, amount);
            // sell
            amountReceived = !shouldTakeFee(sender) || !shouldTakeFee(recipient)
                ? amount
                : takeFee(
                    sender,
                    amount,
                    allFees.sellTotal,
                    allFees.sellFeeDenominator
                );
            ICalculator(calculator).registerBuySell(amount, false);
            if (whenProcess.onSell) {
                try distributor.process(distributorGas) {} catch {}
            }
        } else if (pairs[sender]) {
            // buy
            amountReceived = !shouldTakeFee(sender) || !shouldTakeFee(recipient)
                ? amount
                : takeFee(
                    sender,
                    amount,
                    allFees.buyTotal,
                    allFees.buyFeeDenominator
                );
            ICalculator(calculator).registerBuySell(amount, true);
            if (whenProcess.onBuy) {
                try distributor.process(distributorGas) {} catch {}
            }
        } else if (allFees.transferFee > 0) {
            amountReceived = !shouldTakeFee(sender) || !shouldTakeFee(recipient)
                ? amount
                : takeFee(
                    sender,
                    amount,
                    allFees.transferFee,
                    allFees.buyFeeDenominator
                );
            if (timeOfSell[sender] + 1 days > block.timestamp) {
                timeOfSell[recipient] = timeOfSell[sender];
                amountOfSell[recipient] = amountOfSell[sender];
            }
            if (whenProcess.onTransfer) {
                try distributor.process(distributorGas) {} catch {}
            }
        } else {
            amountReceived = amount;
            if (timeOfSell[sender] + 1 days > block.timestamp) {
                timeOfSell[recipient] = timeOfSell[sender];
                amountOfSell[recipient] = amountOfSell[sender];
            }
            if (whenProcess.onTransfer) {
                try distributor.process(distributorGas) {} catch {}
            }
        }

        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        _balances[recipient] = _balances[recipient].add(amountReceived);

        if (!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }
        if (!isDividendExempt[recipient]) {
            try
                distributor.setShare(recipient, _balances[recipient])
            {} catch {}
        }
        setStakes(sender, recipient);
        updateRouterIndex();
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function setStakes(address sender, address recipient) internal {
        try reflectoRewards._updateRewardsPerToken() {} catch {}
        try reflectoRewards._updateUserRewards(sender) {} catch {}
        try reflectoRewards._updateUserRewards(recipient) {} catch {}
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal {
        if (timeOfSell[sender] + 1 days < block.timestamp) {
            amountOfSell[sender] = 0;
        }
        require(
            (amount + amountOfSell[sender] <= sellLimit) ||
                isTxLimitExempt[sender],
            "Exceeded TX daily limit"
        );

        timeOfSell[sender] = block.timestamp;
        amountOfSell[sender] = amountOfSell[sender] + amount;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(
        address sender,
        uint256 amount,
        uint256 totalFee,
        uint256 denominator
    ) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(denominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function shouldSwapBack(address recipient, uint256 _swapThreshold)
        internal
        view
        returns (bool)
    {
        return
            (pairs[recipient] || !isSwapOnSell) &&
            !pairs[msg.sender] &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= _swapThreshold;
    }

    function sendToThePool(uint256 _swapThreshold) internal returns (bool) {
        if (!isSentToPoolEnabled) {
            return true;
        }
        // return true if disabled
        (bool shoudFundByPressure, uint256 amount) = ICalculator(calculator)
            .getFundPoolByPressureData(
                _swapThreshold,
                address(reflectoRewards),
                minimumStakingLimit
            );
        if (shoudFundByPressure) {
            fundStakingPool(amount);
            return false;
        }
        return true;
    }

    function fundStakingPool(uint256 amount) internal {
        _balances[address(this)] = _balances[address(this)].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[address(reflectoRewards)] = _balances[
            address(reflectoRewards)
        ].add(amount);
        emit Transfer(address(this), address(reflectoRewards), amount);
    }

    function algoBB(bool isSell, uint256 amount) internal {
        IDEXRouter router = getRouter();
        address pairOfRouter = IDEXFactory(router.factory()).getPair(
            isBNBRouter[address(router)] ? router.WBNB() : router.WETH(),
            address(this)
        );

        (bool shouldBB, uint256 amountToBuy) = ICalculator(calculator)
            .getAlgoBuybackData(amount, isSell, pairOfRouter);

        if (!shouldBB) {
            return;
        }

        uint256 beforeBB = _balances[DEAD];
        buyTokens(amountToBuy, DEAD);
        burnCounter = burnCounter.add(_balances[DEAD].sub(beforeBB));
    }

    function getPath(IDEXRouter router)
        internal
        view
        returns (address[] memory)
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = isBNBRouter[address(router)] ? router.WBNB() : router.WETH();
        return path;
    }

    function swapBack(Swap memory swap) internal swapping {
        if (!sendToThePool(swap.swapThreshold)) {
            return;
        }
        IDEXRouter router = getRouter();
        address pairOfRouter = IDEXFactory(router.factory()).getPair(
            isBNBRouter[address(router)] ? router.WBNB() : router.WETH(),
            address(this)
        );

        uint256 dynamicLiquidityFee = isOverLiquified(
            targetLiquidity,
            targetLiquidityDenominator,
            pairOfRouter
        )
            ? 0
            : swap.liquidityFee;
        uint256 amountToLiquify = swap
            .swapThreshold
            .mul(dynamicLiquidityFee)
            .div(swap.totalFee)
            .div(2);
        uint256 amountToSwap = swap.swapThreshold.sub(amountToLiquify);
        (uint256 priceDataBeforeSwap, , ) = ICalculator(calculator).getPrices(
            pairOfRouter
        );
        uint256 balanceBefore = address(this).balance;

        isBNBRouter[address(router)]
            ? router.swapExactTokensForBNBSupportingFeeOnTransferTokens(
                amountToSwap,
                0,
                getPath(router),
                address(this),
                block.timestamp
            )
            : router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amountToSwap,
                0,
                getPath(router),
                address(this),
                block.timestamp
            );
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = swap.totalFee.sub(dynamicLiquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB
            .mul(dynamicLiquidityFee)
            .div(totalBNBFee)
            .div(2);

        try
            distributor.deposit{
                value: amountBNB.mul(swap.reflectionFee).div(totalBNBFee)
            }()
        {} catch {}
        payable(marketingFeeReceiver).transfer(
            amountBNB.mul(swap.marketingFee).div(totalBNBFee)
        );
        payable(gasWalletFeeReceiver).transfer(
            amountBNB.mul(swap.gasWalletFee).div(totalBNBFee)
        );
        if (amountToLiquify > 0) {
            isBNBRouter[address(router)]
                ? router.addLiquidityBNB{value: amountBNBLiquidity}(
                    address(this),
                    amountToLiquify,
                    0,
                    0,
                    autoLiquidityReceiver,
                    block.timestamp
                )
                : router.addLiquidityETH{value: amountBNBLiquidity}(
                    address(this),
                    amountToLiquify,
                    0,
                    0,
                    autoLiquidityReceiver,
                    block.timestamp
                );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }

        if (isCancelingEnabled) {
            (
                bool sholdCancel,
                uint256 cancelingAmount,
                address targetAddress
            ) = ICalculator(calculator).getSellCancelingAmount(
                    pairOfRouter,
                    priceDataBeforeSwap
                );
            if (
                _balances[targetAddress] >= cancelingAmount &&
                cancelingAmount > 0 &&
                cancelingAmount <= maxCancelingAmount &&
                sholdCancel
            ) {
                if (burnDivider > 0) {
                    cancelingAmount = cancelingAmount.div(burnDivider);
                }
                _balances[targetAddress] = _balances[targetAddress].sub(
                    cancelingAmount
                );
                _totalSupply = _totalSupply.sub(cancelingAmount);
                try reflectoRewards._updateRewardsPerToken() {} catch {}
                IProviderPair(pairOfRouter).sync();
            }
        }
    }

    function shouldAutoBuyback() internal view returns (bool) {
        return
            !pairs[msg.sender] &&
            !inSwap &&
            autoBuybackEnabled &&
            autoBuybackBlockLast + autoBuybackBlockPeriod <= block.timestamp;
    }

    function triggerZeusBuyback(uint256 amount, bool triggerBuybackMultiplier)
        external
        authorized
    {
        uint256 beforeBB = _balances[DEAD];
        buyTokens(amount, DEAD);
        burnCounter = burnCounter + _balances[DEAD].sub(beforeBB);
        if (triggerBuybackMultiplier) {
            buybackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(buybackMultiplierLength);
        }
    }

    function clearBuybackMultiplier() external authorized {
        buybackMultiplierTriggeredAt = 0;
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        IDEXRouter selectedRouter = !isRoundRobinBuyback
            ? defaultRouter
            : getRouter();
        address WBNB_OR_WETH = isBNBRouter[address(selectedRouter)]
            ? selectedRouter.WBNB()
            : selectedRouter.WETH();
        path[0] = WBNB_OR_WETH;
        path[1] = address(this);

        isBNBRouter[address(selectedRouter)]
            ? selectedRouter.swapExactBNBForTokensSupportingFeeOnTransferTokens{
                value: amount
            }(0, path, to, block.timestamp)
            : selectedRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: amount
            }(0, path, to, block.timestamp);
    }

    function setAutoBuybackSettings(bool _enabled, uint256 period)
        external
        authorized
    {
        autoBuybackEnabled = _enabled;
        autoBuybackBlockPeriod = period;
    }

    function setDividendDistributer(address distributer) external authorized {
        isDividendExempt[distributer] = true;
        isFeeExempt[distributer] = true;
        distributor = DividendDistributor(distributer);
    }

    function setBuybackMultiplierSettings(
        uint256 numerator,
        uint256 denominator,
        uint256 length
    ) external authorized {
        require(numerator / denominator <= 2 && numerator > denominator);
        buybackMultiplierNumerator = numerator;
        buybackMultiplierDenominator = denominator;
        buybackMultiplierLength = length;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() public authorized {
        require(launchedAt == 0, "Already launched.");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
    }

    function setSellLimit(uint256 amount) external authorized {
        require(
            amount >= 100000000000000000000,
            "Put amount greater then 100b"
        );
        sellLimit = amount;
    }

    function setIsDividendExempt(address holder, bool exempt)
        external
        authorized
    {
        require(holder != address(this) && !pairs[holder]);
        isDividendExempt[holder] = exempt;
        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt)
        external
        authorized
    {
        isTxLimitExempt[holder] = exempt;
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _marketingFeeReceiver,
        address _gasWalletReceiver
    ) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        gasWalletFeeReceiver = _gasWalletReceiver;
    }

    function setSwapBackSettings(bool _enabled) external authorized {
        swapEnabled = _enabled;
    }

    function setSwapBackOnSell(bool _isSwapBackOnSell) external authorized {
        isSwapOnSell = _isSwapBackOnSell;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator)
        external
        authorized
    {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 999999);
        distributorGas = gas;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy, address pair)
        public
        view
        returns (uint256)
    {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(
        uint256 target,
        uint256 accuracy,
        address pair
    ) public view returns (bool) {
        return getLiquidityBacking(accuracy, pair) > target;
    }

    /**
     * @dev Sets the allowance granted to `spender` by `owner`.
     *
     * Emits an {Approval} event indicating the updated allowance.
     */
    function _setAllowance(
        address owner,
        address spender,
        uint256 wad
    ) internal virtual returns (bool) {
        _allowances[owner][spender] = wad;
        emit Approval(owner, spender, wad);

        return true;
    }

    // --- Approve by signature ---
    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        holder,
                        spender,
                        nonce,
                        expiry,
                        allowed
                    )
                )
            )
        );

        require(holder != address(0), "Reflecto/invalid-address-0");
        require(
            holder == ecrecover(digest, v, r, s),
            "Reflecto/invalid-permit"
        );
        require(
            expiry == 0 || block.timestamp <= expiry,
            "Reflecto/permit-expired"
        );
        require(nonce == nonces[holder]++, "Reflecto/invalid-nonce");
        uint256 wad = allowed ? _totalSupply : 0;
        _setAllowance(holder, spender, wad);
    }

    function convertTokensToBuyBack(address token) external authorized {
        address[] memory bnbPath = new address[](2);
        address WBNB_OR_WETH = isBNBRouter[address(defaultRouter)]
            ? defaultRouter.WBNB()
            : defaultRouter.WETH();
        bnbPath[0] = token;
        bnbPath[1] = WBNB_OR_WETH;
        uint256 amountIn = IBEP20(token).balanceOf(address(this));

        uint256 deadline = block.timestamp + 1000;
        IBEP20(token).approve(address(defaultRouter), amountIn);

        isBNBRouter[address(defaultRouter)]
            ? defaultRouter.swapExactTokensForBNBSupportingFeeOnTransferTokens(
                amountIn,
                0,
                bnbPath,
                address(this),
                deadline
            )
            : defaultRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amountIn,
                0,
                bnbPath,
                address(this),
                deadline
            );
    }

    function burnTokenFromContract() external authorized {
        uint256 balanceOfContract = balanceOf(address(this));
        uint256 swapThreshold = ICalculator(calculator).getSwapThreshold();
        require(
            balanceOfContract > swapThreshold,
            "Threshold is gt then blance"
        );

        uint256 amountToBurn = balanceOfContract - swapThreshold;

        _balances[address(this)] = _balances[address(this)].sub(
            amountToBurn,
            "Insufficient Balance"
        );
        _balances[DEAD] = _balances[DEAD].add(amountToBurn);
        burnCounter = burnCounter.add(amountToBurn);

        emit Transfer(address(this), DEAD, amountToBurn);
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event BuybackMultiplierActive(uint256 duration);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * SAFEMATH LIBRARY
 */
library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function WBNB() external pure returns (address);

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

    function addLiquidityBNB(
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

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
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

    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IProviderPair {
    function getReserves()
        external
        view
        returns (
            uint112,
            uint112,
            uint32
        );

    function sync() external;

    function token0() external view returns (address);

    function token1() external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
struct Fees {
    uint256 buyLiquidityFee;
    uint256 sellLiquidityFee;
    uint256 buyBuybackFee;
    uint256 sellBuybackFee;
    uint256 buyGasWalletFee;
    uint256 sellGasWalletFee;
    uint256 buyReflectionFee;
    uint256 sellReflectionFee;
    uint256 buyDevelopmentFee;
    uint256 sellDevelopmentFee;
    uint256 buyTotal;
    uint256 sellTotal;
    uint256 buyFeeDenominator;
    uint256 sellFeeDenominator;
    uint256 transferFee;
}

interface ICalculator {
    function getFees() external view returns (Fees memory);

    function registerBuySell(uint256 amount, bool isBuy) external;

    function isCustomFeeReceiverOrSender(address sender, address receiver)
        external
        view
        returns (bool);

    function getPressure() external view returns (uint256, uint256);

    function getFundPoolByPressureData(
        uint256 swapThreshold,
        address poolAddress,
        uint256 minPoolAmount
    ) external view returns (bool, uint256);

    function getSwapThreshold() external view returns (uint256);

    function getUserFees(address sender, address receiver)
        external
        view
        returns (Fees memory);
    
    function getAlgoBuybackData(
        uint256 amount,
        bool isSell,
        address pair
    ) external view returns (bool, uint256);

    function getSellCancelingAmount(address pair, uint256 priceDataBeforeSwap)
        external
        view
        returns (bool, uint256, address);

    function getPrices(address ratePair)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./libs/IDividendDistributor.sol";
import "./libs/SafeMath.sol";
import "./libs/IBEP20.sol";
import "./libs/IDEX.sol";

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract DividendDistributor is IDividendDistributor, ReentrancyGuard {
    using SafeMath for uint256;

    address _owner;
    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
        address[] tokensToDistribute;
        uint256 tokenIndexDistributed;
        bool isInit;
    }

    address public WBNB;
    IDEXRouter public router;
    IDEXRouter public ourDexRouter;
    bool public roundRobinEnabled = false;
    bool public isOurDexRouter = true;
    mapping(address => bool) public isTokenSupportedOnOurDex;

    address defaultRewardToken = 0x4Be8c674C51674bEb729832682bBA5E5b105b6e2;
    address defaultForContracts = 0x4Be8c674C51674bEb729832682bBA5E5b105b6e2;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) shareholderClaims;

    mapping(address => Share) public shares;
    mapping(address => bool) public allRewardTokens;

    address[] public allRewardsTokenList;

    mapping(address => bool) public blacklistedTokens;

    mapping(address => uint256) public rewardTokenExpirationTime;
    mapping(address => uint256) public rewardTokenFeePaid;
    address[] public allPendingRewardsTokenList;
    mapping(address => bool) private pendingRewardTokens;
    mapping(address => address) private rewardTokenFeePayers;

    mapping(address => uint256) public dividendsDistributedPerToken;
    mapping(address => uint256) public shouldClaimOnSetShare;
    mapping(address => mapping(address => uint256))
        public dividendsDistributedPerUser;

    mapping(address => IDEXRouter) public customRouter;
    mapping(address => bool) public haveCustomRouter;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 0.001 * (10**18);

    uint256 public feeForTokenListening = 20 ether;
    uint256 public feeExpirationInDays = 30 days;

    uint256 public addMyTokenFee = 10000000000000000;
    mapping(address => bool) public tokensToListFree;

    mapping(address => uint256) gaslessClaimTimestamp;

    uint256 public gaslessClaimPeriod = 86400;

    address public feeAddress;

    uint256 currentIndex;

    bool initialized;

    event RewardTokenTransferFailed(uint256 time, address tokenAddress);
    event RewardTokenTransferSuccess(
        uint256 time,
        address tokenAddress,
        address holder,
        uint256 amount
    );

    event ListToken(
        address rewardToken,
        uint256 expirationTime,
        uint256 status
    );
    event AllowAddingButNotListToken(address rewardToken, uint256 status);
    event BlackListToken(address rewardToken);

    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor(address _router, address reflecto) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _owner = msg.sender;
        feeAddress = msg.sender;
        _token = reflecto;
        WBNB = router.WETH();

        allRewardTokens[defaultRewardToken] = true;
        allRewardsTokenList.push(defaultRewardToken);
        rewardTokenExpirationTime[defaultRewardToken] =
            block.timestamp +
            36525 days;
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setAddMyTokenFee(uint256 _addMyTokenFee) external onlyOwner {
        addMyTokenFee = _addMyTokenFee;
    }

    function setFreeMyTokenToAdd(address _rewardToken, bool _isFree)
        external
        onlyOwner
    {
        tokensToListFree[_rewardToken] = _isFree;
    }

    function rewardsTokensCount() public view returns (uint256 count) {
        return allRewardsTokenList.length;
    }

    function rewardsTokens()
        public
        view
        returns (address[] memory rewardTokens)
    {
        return allRewardsTokenList;
    }

    function pendingRewardsTokens()
        public
        view
        returns (address[] memory rewardTokens)
    {
        return allPendingRewardsTokenList;
    }

    function getUsersRewardsTokens(address shareholder)
        public
        view
        returns (address[] memory token)
    {
        return shares[shareholder].tokensToDistribute;
    }

    function getUsersTotalEarned(address shareholder)
        public
        view
        returns (uint256)
    {
        return shares[shareholder].totalRealised;
    }

    function setTokenListeningExpirationIn(uint256 time) external onlyOwner {
        feeExpirationInDays = time;
    }

    function setOwnRouter(address _router) external onlyOwner {
        ourDexRouter = IDEXRouter(_router);
    }

    function setTokenSupportedByOurDex(
        address _tokenOnOurDex,
        bool _isSupported
    ) external onlyOwner {
        isTokenSupportedOnOurDex[_tokenOnOurDex] = _isSupported;
    }

    function setOtherRouter(address _router) external onlyOwner {
        router = IDEXRouter(_router);
        WBNB = router.WETH();
    }

    function setCustomRouter(
        address _rewardToken,
        address _router,
        bool isSet
    ) external onlyOwner {
        customRouter[_rewardToken] = IDEXRouter(_router);
        haveCustomRouter[_rewardToken] = isSet;
    }

    function setRoundRoubinRouter(bool _isEnabled) external onlyOwner {
        roundRobinEnabled = _isEnabled;
    }

    function getRouter(address tokenSupportedByOwnDex)
        internal
        returns (IDEXRouter)
    {
        if (haveCustomRouter[tokenSupportedByOwnDex]) {
            return customRouter[tokenSupportedByOwnDex];
        }
        if (!roundRobinEnabled) {
            return router;
        }
        if (!isTokenSupportedOnOurDex[tokenSupportedByOwnDex]) {
            return router;
        }

        if (!isOurDexRouter) {
            isOurDexRouter = true;
            return router;
        }
        isOurDexRouter = false;
        return ourDexRouter;
    }

    function setDefaultRewardTokenForContracts(address _defaultForContracts)
        external
        onlyOwner
    {
        defaultForContracts = _defaultForContracts;
    }

    function setDefaultRewardToken(address rewardToken) external onlyOwner {
        defaultRewardToken = rewardToken;
        allRewardTokens[rewardToken] = true;
        allRewardsTokenList.push(rewardToken);
        rewardTokenExpirationTime[rewardToken] = block.timestamp + 36525 days;
    }

    function addRewardTokenToList(address rewardToken, uint256 duration)
        external
        onlyOwner
    {
        allRewardTokens[rewardToken] = true;
        allRewardsTokenList.push(rewardToken);
        rewardTokenExpirationTime[rewardToken] = block.timestamp + duration;
        emit ListToken(rewardToken, block.timestamp + duration, 1);
    }

    function approveTokenAdding(address rewardToken) external onlyOwner {
        allRewardTokens[rewardToken] = true;
        emit AllowAddingButNotListToken(rewardToken, 1);
    }

    function rejectTokenAdding(address rewardToken) external onlyOwner {
        require(
            rewardToken != address(defaultRewardToken),
            "Cannot disable default token"
        );
        allRewardTokens[rewardToken] = false;
        emit AllowAddingButNotListToken(rewardToken, 2);
    }

    function blacklistRewardToken(address rewardToken, bool isBlacklisted)
        external
        onlyOwner
    {
        blacklistedTokens[rewardToken] = isBlacklisted;
        emit BlackListToken(rewardToken);
    }

    function removeRewardTokenFromList(uint256 index, address rewardToken)
        external
        onlyOwner
    {
        require(allRewardsTokenList[index] == rewardToken, "Index not correct");
        if (allRewardsTokenList[index] != address(defaultRewardToken)) {
            allRewardTokens[rewardToken] = false;
        }
        removeItemFromArray(allRewardsTokenList, index);
        emit ListToken(rewardToken, 0, 2);
    }

    function setFeeAddress(address feeTo) external onlyOwner {
        feeAddress = feeTo;
    }

    function setReflectoAddress(address reflectoAddress) external onlyOwner {
        _token = reflectoAddress;
    }

    function setListeningFee(uint256 fee) external onlyOwner {
        feeForTokenListening = fee;
    }

    function setShare(address shareholder, uint256 amount)
        external
        override
        onlyToken
    {
        if (!shares[shareholder].isInit) {
            shares[shareholder].tokensToDistribute = [defaultRewardToken];
            shares[shareholder].tokenIndexDistributed = 0;
            shares[shareholder].isInit = true;
        }

        if (
            shares[shareholder].amount > 0 &&
            shouldClaimOnSetShare[shareholder] + 40 < block.timestamp
        ) {
            shouldClaimOnSetShare[shareholder] = block.timestamp;
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;

        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function migrate(address[] memory rshareholders, address oldDis)
        external
        onlyOwner
    {
        uint256 total = 0;
        for (uint256 i = 0; i < rshareholders.length; i++) {
            uint256 balance = IDividendDistributorOld(oldDis)
                .getShareholderAmount(rshareholders[i]);
            if (balance == 0 || shares[rshareholders[i]].amount > 0) {
                continue;
            }

            shares[rshareholders[i]]
                .tokensToDistribute = IDividendDistributorOld(oldDis)
                .getUsersRewardsTokens(rshareholders[i]);
            shares[rshareholders[i]].totalRealised = 0;

            shares[rshareholders[i]].tokenIndexDistributed = 0;
            shares[rshareholders[i]].isInit = true;
            shares[rshareholders[i]].amount = balance;
            shares[rshareholders[i]].totalExcluded = getCumulativeDividends(
                balance
            );
            addShareholder(rshareholders[i]);
            total = total.add(balance);
        }

        totalShares = totalShares.add(total);
    }

    function migrateTokens(
        address[] memory _rewardTokens,
        uint256[] memory _durations,
        uint256[] memory _dividendsDistributedPerTokens
    ) external onlyOwner {
        for (uint256 i = 0; i < _rewardTokens.length; i++) {
            if (allRewardTokens[_rewardTokens[i]]) {
                continue;
            }
            allRewardTokens[_rewardTokens[i]] = true;
            allRewardsTokenList.push(_rewardTokens[i]);
            rewardTokenExpirationTime[_rewardTokens[i]] =
                block.timestamp +
                _durations[i];
            dividendsDistributedPerToken[
                _rewardTokens[i]
            ] = _dividendsDistributedPerTokens[i];
        }
    }

    // TODO: add external fallback function
    function deposit() external payable override onlyToken {
        uint256 amount = msg.value;

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)
        );
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex])) {
                shouldClaimOnSetShare[shareholders[currentIndex]] = block
                    .timestamp;
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder)
        internal
        view
        returns (bool)
    {
        return
            shareholderClaims[shareholder] + minPeriod < block.timestamp &&
            getUnpaidEarnings(shareholder) > minDistribution;
    }

    function listMyToken(address rewardToken) external payable {
        require(
            msg.value == feeForTokenListening,
            "Send correct amount for listening"
        );

        require(
            !pendingRewardTokens[rewardToken],
            "Reward token already waiting for approval"
        );

        require(!allRewardTokens[rewardToken], "This token is already listed");

        require(
            allRewardsTokenList.length < 100,
            "Maximum 100 tokens allowed to be on list"
        );
        // addTokenToPending list
        allPendingRewardsTokenList.push(rewardToken);
        emit ListToken(rewardToken, 0, 0);
        // set amount fee
        rewardTokenFeePaid[rewardToken] = msg.value;

        rewardTokenFeePayers[rewardToken] = msg.sender;

        pendingRewardTokens[rewardToken] = true;
    }

    function approveToken(address rewardToken, uint256 index)
        external
        onlyOwner
    {
        require(
            allPendingRewardsTokenList[index] == rewardToken,
            "Index not correct"
        );
        allRewardTokens[rewardToken] = true;
        allRewardsTokenList.push(rewardToken);

        // remove token from pending
        removeItemFromArray(allPendingRewardsTokenList, index);

        // set time when expires
        rewardTokenExpirationTime[rewardToken] =
            block.timestamp +
            feeExpirationInDays;
        payable(feeAddress).transfer(rewardTokenFeePaid[rewardToken]);
        pendingRewardTokens[rewardToken] = false;

        emit ListToken(rewardToken, rewardTokenExpirationTime[rewardToken], 1);
    }

    function rejectToken(address rewardToken, uint256 index)
        external
        onlyOwner
    {
        require(
            allPendingRewardsTokenList[index] == rewardToken,
            "Index not correct"
        );

        // remove token from pending
        removeItemFromArray(allPendingRewardsTokenList, index);

        pendingRewardTokens[rewardToken] = false;

        // retuurn fee
        payable(rewardTokenFeePayers[rewardToken]).transfer(
            rewardTokenFeePaid[rewardToken]
        );
        emit ListToken(rewardToken, 0, 2);
    }

    function closeExpiredListenings() external {
        for (uint256 i = 0; i < allRewardsTokenList.length; i++) {
            if (
                block.timestamp >
                rewardTokenExpirationTime[allRewardsTokenList[i]]
            ) {
                emit ListToken(allRewardsTokenList[i], 0, 4);
                allRewardTokens[allRewardsTokenList[i]] = false;
                removeItemFromArray(allRewardsTokenList, i);
            }
        }
    }

    function removeItemFromArray(address[] storage array, uint256 index)
        internal
    {
        array[index] = array[array.length - 1];
        array.pop();
    }

    function addMyRewardToken(address rewardToken) external payable {
        require(
            msg.value == addMyTokenFee || tokensToListFree[rewardToken],
            "This token cannot be listed free"
        );
        require(
            shares[msg.sender].isInit,
            "You need to get Reflecto to be able to set rewards"
        );

        require(
            shares[msg.sender].tokensToDistribute.length <= 12,
            "Maximum 12 tokens allowed"
        );

        require(
            allRewardTokens[rewardToken],
            "Token is not listed on Reflecto"
        );
        for (
            uint256 i = 0;
            i < shares[msg.sender].tokensToDistribute.length;
            i++
        ) {
            if (shares[msg.sender].tokensToDistribute[i] == rewardToken) {
                revert("This token has already added as reward token");
            }
        }

        payable(feeAddress).transfer(msg.value);

        shares[msg.sender].tokensToDistribute.push(rewardToken);
    }

    function removeMyRewardToken(address rewardToken, uint256 index) external {
        require(
            shares[msg.sender].isInit,
            "You need to get Reflecto to be able do remove token"
        );

        require(
            shares[msg.sender].tokensToDistribute[index] == rewardToken,
            "Not correct index"
        );
        removeItemFromArray(shares[msg.sender].tokensToDistribute, index);
        shares[msg.sender].tokenIndexDistributed = 0;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);

        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);

            uint256 totalRewardsTokens = shares[shareholder]
                .tokensToDistribute
                .length;
            if (totalRewardsTokens > 0) {
                address rewardToken = shares[shareholder].tokensToDistribute[
                    shares[shareholder].tokenIndexDistributed
                ];

                if (WBNB != rewardToken && !blacklistedTokens[rewardToken]) {
                    sentRewardInToken(shareholder, amount, rewardToken);
                } else if (!isContract(shareholder)) {
                    sentRewardInBNB(shareholder, amount);
                } else {
                    sentRewardInToken(shareholder, amount, defaultForContracts);
                }

                emit RewardTokenTransferSuccess(
                    block.timestamp,
                    rewardToken,
                    shareholder,
                    amount
                );

                if (
                    shares[shareholder].tokenIndexDistributed + 1 >
                    totalRewardsTokens - 1
                ) {
                    shares[shareholder].tokenIndexDistributed = 0;
                } else {
                    shares[shareholder].tokenIndexDistributed =
                        shares[shareholder].tokenIndexDistributed +
                        1;
                }
            } else if (!isContract(shareholder)) {
                sentRewardInBNB(shareholder, amount);
            } else {
                sentRewardInToken(shareholder, amount, defaultForContracts);
            }

            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder]
                .totalRealised
                .add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function distributeDividendClaim(
        address shareholder,
        address rewardToken,
        uint256 devidedBy,
        uint256 amount
    ) internal {
        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);

            uint256 totalRewardsTokens = devidedBy;
            if (totalRewardsTokens > 0) {
                if (WBNB != rewardToken && !blacklistedTokens[rewardToken]) {
                    sentRewardInToken(shareholder, amount, rewardToken);
                } else {
                    sentRewardInBNB(shareholder, amount);
                }

                emit RewardTokenTransferSuccess(
                    block.timestamp,
                    rewardToken,
                    shareholder,
                    amount
                );
            } else {
                sentRewardInBNB(shareholder, amount);
            }

            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder]
                .totalRealised
                .add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function sentRewardInBNB(address shareholder, uint256 amount) internal {
        uint256 balanceBefore = shareholder.balance;
        payable(shareholder).transfer(amount);
        uint256 balanceToAdd = shareholder.balance.sub(balanceBefore);
        dividendsDistributedPerToken[WBNB] = dividendsDistributedPerToken[WBNB]
            .add(balanceToAdd);

        dividendsDistributedPerUser[shareholder][
            WBNB
        ] = dividendsDistributedPerUser[shareholder][WBNB].add(balanceToAdd);
    }

    function sentRewardInToken(
        address shareholder,
        uint256 amount,
        address rewardTokenAddress
    ) internal {
        IBEP20 rewardToken = IBEP20(rewardTokenAddress);
        address[] memory path = new address[](2);
        IDEXRouter routerInst = getRouter(rewardTokenAddress);
        path[0] = routerInst.WETH();
        path[1] = rewardTokenAddress;
        uint256 amountBefore = rewardToken.balanceOf(shareholder);

        try
            routerInst.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: amount
            }(0, path, shareholder, block.timestamp + 100)
        {
            uint256 amountAfter = rewardToken.balanceOf(shareholder);

            dividendsDistributedPerToken[
                rewardTokenAddress
            ] = dividendsDistributedPerToken[rewardTokenAddress].add(
                amountAfter.sub(amountBefore)
            );

            dividendsDistributedPerUser[shareholder][
                rewardTokenAddress
            ] = dividendsDistributedPerUser[shareholder][rewardTokenAddress]
                .add(amountAfter.sub(amountBefore));
        } catch Error(string memory reason) {
            sentRewardInBNB(shareholder, amount);
            emit RewardTokenTransferFailed(block.timestamp, rewardTokenAddress);
        }
    }

    function claimDividend(address shareholder, address[] memory rewardTokens)
        external
        nonReentrant
    {
        claim(shareholder, rewardTokens);
    }

    function claim(address shareholder, address[] memory rewardTokens)
        internal
    {
        if (shares[shareholder].amount == 0) {
            revert("No Reflecto in account");
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        require(amount > 0, "Amount must be greater than zero");
        uint256 amountPerToken = amount.div(rewardTokens.length);
        for (uint256 i = 0; i < rewardTokens.length; i++) {
            if (!allRewardTokens[rewardTokens[i]]) {
                revert("Select reward token not listed");
            }
            distributeDividendClaim(
                shareholder,
                rewardTokens[i],
                rewardTokens.length,
                amountPerToken
            );
        }
    }

    function gaslessClaim(
        address _to,
        address[] memory _rewardTokens,
        bytes32 _messageHash,
        bytes memory signature
    ) external onlyOwner nonReentrant {
        require(
            block.timestamp >=
                gaslessClaimTimestamp[_to].add(gaslessClaimPeriod),
            "Cannot reclaim before 1 day"
        );
        require(
            verify(_to, _messageHash, signature),
            "signature is not matching"
        );
        gaslessClaimTimestamp[_to] = block.timestamp;
        claim(_to, _rewardTokens);
    }

    function getMessageHash(
        address _to,
        uint256 _amount,
        string memory _message,
        uint256 _nonceH
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonceH));
    }

    function verify(
        address _signer,
        bytes32 _messageHash,
        bytes memory signature
    ) internal pure returns (bool) {
        return recoverSigner(_messageHash, signature) == _signer;
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // return (r, s, v);
    }

    function setClaimPeriod(uint256 gaslessClaimPeriod_) external onlyOwner {
        gaslessClaimPeriod = gaslessClaimPeriod_;
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share)
        internal
        view
        returns (uint256)
    {
        return
            share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function getShareholders()
        external
        view
        onlyOwner
        returns (address[] memory)
    {
        return shareholders;
    }

    function getShareholderAmount(address shareholder)
        external
        view
        returns (uint256)
    {
        return shares[shareholder].amount;
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;
}

interface IDividendDistributorOld {
    function getUsersRewardsTokens(address shareholder)
        external view
        returns (address[] memory token);

    function getShareholderAmount(address shareholder)
        external
        view
        returns (uint256);
}
