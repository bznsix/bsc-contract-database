//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping(address => uint256) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = 1;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender) == 1, "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender) == 1, "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = 1;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = 0;
    }

    function isOwner(address account) public view returns (uint256) {
        return (account == owner ? 1 : 0);
    }

    function isAuthorized(address adr) public view returns (uint256) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = 1;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

interface IRewardDistributor {
    function setShare(address shareholder, uint256 amount, uint256 fullTradingEnabled, uint256 soldMore) external;

    function deposit() external payable;
}

contract RewardDistributor is IRewardDistributor {
    struct RewardShare {
        uint256 amount;
        uint256 totalRealised;
    }

    IBEP20 reward = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IDEXRouter router;

    address token;
    address[] public shareholders;
    address[] public diamondHolders;

    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) diamondHolderIndexes;
    mapping(address => uint256) public isDiamondHand;
    mapping(address => mapping(uint256 => uint256)) public isDistributed;
    mapping(address => uint256) public shares;
    mapping(address => RewardShare) public rewardShares;

    uint256 public currentIndex;
    uint256 public currentCycle;
    uint256 public totalRewardAmount;
    uint256 public totalShares;
    uint256 public totalRewardShares;
    uint256 public totalRewardDistributed;
    uint256 public rewardPerShare;
    uint256 public finalRewardPerShare;
    uint256 public rewardPerShareAccuracyFactor = 10 ** 36;
    uint256 public mockPeriod = 0;

    modifier onlyToken() {
        require(msg.sender == token); _;
    }

    constructor (address _router) {
        router = IDEXRouter(_router);
        token = msg.sender;
    }

    function getShareholderCount() external view returns(uint256 count) {
        return shareholders.length;
    }

    function getDiamondHolderCount() external view returns(uint256 count) {
        return diamondHolders.length;
    }

    function removePresaleAddress(address presaleAddress) external onlyToken {
        if (shares[presaleAddress] > 0) {
            removeShareholder(presaleAddress);
        }
        totalShares -= shares[presaleAddress];
        totalRewardShares -= rewardShares[presaleAddress].amount;
        shares[presaleAddress] = 0;
        rewardShares[presaleAddress].amount = 0;
    }

    function setMockPeriod() external onlyToken {
        mockPeriod = 1;
        finalRewardPerShare = rewardPerShare;
    }

    function setReward(address _reward) external onlyToken {
        reward = IBEP20(_reward);
    }

    function setShare(address shareholder, uint256 amount, uint256 fullTradingEnabled, uint256 soldMore) external override onlyToken {
        uint256 setTotalRewardShares = 0;
        uint256 cachedTotalRewardShares = totalRewardShares;
        uint256 cachedRewardShares = rewardShares[shareholder].amount;

        if (mockPeriod == 1 && isDistributed[shareholder][currentCycle] == 0) {
            isDistributed[shareholder][currentCycle] = 1;
            distributeReward(shareholder);
        }

        if (amount == 0 && shares[shareholder] > 0) {
            removeShareholder(shareholder);
            setTotalRewardShares = 1;
        }
        else if (soldMore == 1 && isDiamondHand[shareholder] == 1) {
            removeDiamondHolder(shareholder);
            setTotalRewardShares = 1;
        }
        else if (amount > shares[shareholder]) {
            if (shares[shareholder] == 0) {
                addShareholder(shareholder);
            }

            if (fullTradingEnabled == 0 && isDiamondHand[shareholder] == 0) {
                addDiamondHolder(shareholder);
            }
        }

        totalShares -= shares[shareholder];
        totalShares += amount;
        shares[shareholder] = amount;

        if (setTotalRewardShares == 1) {
            cachedTotalRewardShares -= cachedRewardShares;
            cachedRewardShares = 0;
        }
        else if (soldMore == 0 && isDiamondHand[shareholder] == 1) {
            cachedTotalRewardShares -= cachedRewardShares;
            cachedTotalRewardShares += amount;
            cachedRewardShares = amount;
        }

        if (cachedTotalRewardShares > 0) {
            rewardPerShare = (rewardPerShareAccuracyFactor * totalRewardAmount) / cachedTotalRewardShares;
        }
        else {
            rewardPerShare = 0;
        }

        totalRewardShares = cachedTotalRewardShares;
        rewardShares[shareholder].amount = cachedRewardShares;
    }

    function deposit() external payable override onlyToken {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(reward);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value : msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        totalRewardAmount = reward.balanceOf(address(this));
        rewardPerShare = (rewardPerShareAccuracyFactor * totalRewardAmount) / totalRewardShares;
        mockPeriod = 0;
        currentCycle++;
    }

    function claimRewards() external {
        require(mockPeriod == 1 && rewardShares[msg.sender].amount > 0 && isDistributed[msg.sender][currentCycle] == 0, "Not claim time!");
        isDistributed[msg.sender][currentCycle] = 1;
        distributeReward(msg.sender);
    }

    function distributeReward(address shareholder) internal {
        uint256 rewardAmount = getCumulativeRewards(rewardShares[shareholder].amount);
        if (rewardAmount > 0) {
            bool success = reward.transfer(shareholder, rewardAmount);
            if (success) {
                totalRewardDistributed += rewardAmount;
                rewardShares[shareholder].totalRealised += rewardAmount;
            }
            else {
                isDistributed[shareholder][currentCycle] = 0;
            }
        }
    }

    function getUnpaidRewardEarnings(address shareholder) external view returns (uint256) {
        if (isDistributed[shareholder][currentCycle] == 1) {return 0;}
        uint256 shareholderTotalRewards = getCumulativeRewards(rewardShares[shareholder].amount);
        return shareholderTotalRewards;
    }

    function getCumulativeRewards(uint256 share) internal view returns (uint256) {
        return (share * (mockPeriod == 1 ? finalRewardPerShare : rewardPerShare)) / rewardPerShareAccuracyFactor;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function addDiamondHolder(address shareholder) internal {
        diamondHolderIndexes[shareholder] = diamondHolders.length;
        diamondHolders.push(shareholder);
        isDiamondHand[shareholder] = 1;
        if (mockPeriod == 1) {
            isDistributed[shareholder][currentCycle] = 1;
        }
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
        delete shareholderIndexes[shareholder];
        if (diamondHolders.length > 0 && isDiamondHand[shareholder] == 1) {
            removeDiamondHolder(shareholder);
        }
    }

    function removeDiamondHolder(address shareholder) internal {
        diamondHolders[diamondHolderIndexes[shareholder]] = diamondHolders[diamondHolders.length - 1];
        diamondHolderIndexes[diamondHolders[diamondHolders.length - 1]] = diamondHolderIndexes[shareholder];
        diamondHolders.pop();
        delete diamondHolderIndexes[shareholder];
        isDiamondHand[shareholder] = 0;
        isDistributed[shareholder][currentCycle] = 1;
    }
}

contract XProfit is IBEP20, Auth {
    IBEP20 public reward = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address immutable public pair;
    address immutable public distributorAddress;
    address public marketingFeeReceiver;
    address public presaleAddress;
    address public buyBackAddress;

    string constant NAME = 'XProfit';
    string constant SYMBOL = 'XProfit';

    mapping(address => uint256) balances;
    mapping(address => uint256) totalBuyBack;
    mapping(address => mapping(address => uint256)) allowances;
    mapping(address => uint256) public totalPurchased;
    mapping(address => uint256) public isFeeExempt;
    mapping (address => uint256) public isTxLimitExempt;
    mapping(address => uint256) public isRewardExempt;

    uint256 inSwap;
    uint256 resetOn;
    uint256 soldMore;
    uint256 tokenValue;
    uint256 constant DECIMALS = 18;
    uint256 public buyBackAmount;
    uint256 constant TOTAL_SUPPLY = 10 ** 15 * 1 ether;
    uint256 public maxTxAmount = TOTAL_SUPPLY / 200;
    uint256 public rewardFee = 700;
    uint256 public buyBackFee = 100;
    uint256 public marketingFee = 200;
    uint256 public totalFee = 1000;
    uint256 public feeDenominator = 10000;
    uint256 public rate;
    uint256 public multiplier;
    uint256 public denominator;
    uint256 public breakeven;
    uint256 public profit;
    uint256 public launchedAt;
    uint256 public relaunchedAt;
    uint256 public initialMarketCap;
    uint256 public targetMarketCap;
    uint256 public marketCapMultiplier = 10;
    uint256 public marketCapIndex = 1;
    uint256 public swapBackTime;
    uint256 public fullTradingTime;
    uint256 public claimTime;
    uint256 public fullTradingOnTimer = 24 hours;
    uint256 public resetTimer = 365 days;
    uint256 public fullTradingOffTimer = 48 hours;
    uint256 public claimOffTimer = 48 hours;
    uint256 public swapEnabled = 1;
    uint256 public buyBackEnabled = 1;
    uint256 public fullTradingEnabled;

    IDEXRouter immutable router;
    RewardDistributor immutable distributor;

    modifier swapping() { inSwap = 1; _; inSwap = 0; }

    constructor (
        address _dexRouter
    ) Auth(msg.sender) {
        router = IDEXRouter(_dexRouter);
        pair = IDEXFactory(router.factory()).createPair(address(this), router.WETH());
        allowances[address(this)][address(router)] = TOTAL_SUPPLY;
        distributor = new RewardDistributor(_dexRouter);
        distributorAddress = address(distributor);
        isTxLimitExempt[msg.sender] = 1;
        isRewardExempt[msg.sender] = 1;
        isRewardExempt[pair] = 1;
        isRewardExempt[address(this)] = 1;
        isRewardExempt[DEAD] = 1;
        approve(_dexRouter, TOTAL_SUPPLY);
        approve(address(pair), TOTAL_SUPPLY);
        balances[msg.sender] = TOTAL_SUPPLY;
        emit Transfer(address(0), msg.sender, TOTAL_SUPPLY);
    }

    receive() external payable {} // function to receive ether

    function totalSupply() external pure override returns (uint256) {return TOTAL_SUPPLY;}

    function decimals() external pure override returns (uint256) {return DECIMALS;}

    function symbol() external pure override returns (string memory) {return SYMBOL;}

    function name() external pure override returns (string memory) {return NAME;}

    function getOwner() external view override returns (address) {return owner;}

    function balanceOf(address account) public view override returns (uint256) {return balances[account];}

    function allowance(address holder, address spender) external view override returns (uint256) {return allowances[holder][spender];}

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, TOTAL_SUPPLY);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(allowances[sender][msg.sender] != TOTAL_SUPPLY){
            allowances[sender][msg.sender] = sub(allowances[sender][msg.sender], amount);
        }
        return _transferFrom(sender, recipient, amount);
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
        require(b <= a, "Insufficient Allowance");
        return a - b;
    }
    }

    function subBalance(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
        require(b <= a, "Insufficient Balance");
        return a - b;
    }
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(launched() || isFeeExempt[sender] == 1, "Not launched yet!");
        address cachedPair = pair;
        uint256 cachedTotalPurchasedSender = totalPurchased[sender];
        if(inSwap == 1){ return basicTransfer(sender, recipient, amount); }
        if(sender == presaleAddress && isRewardExempt[recipient] == 0) {
            initPresaleInvestor(recipient, amount);
        }
        if(launched() && (sender == cachedPair || recipient == cachedPair)) {
            checkFullTrading();
            tokenValue = getTokenValue(amount);
            checkTxLimit(sender, recipient, amount);
            if(fullTradingEnabled == 0) {
                if(reward.balanceOf(distributorAddress) == 0 || claimTime + claimOffTimer < block.timestamp) {  swapEnabled = 1; }
                if(getCurrentMarketCap() >= targetMarketCap){ shouldSwapBack(recipient); }
            }
            setTotalPurchased(sender, recipient, cachedTotalPurchasedSender);
        }
        else if(isRewardExempt[sender] == 0 && cachedTotalPurchasedSender > 0) {
            tokenValue = getTokenValue(amount);
            if(tokenValue > cachedTotalPurchasedSender) {
                totalPurchased[recipient] += cachedTotalPurchasedSender;
                cachedTotalPurchasedSender = 0;
                totalPurchased[sender] = cachedTotalPurchasedSender;
            }
            else {
                totalPurchased[sender]-= tokenValue;
                totalPurchased[recipient] += tokenValue;
            }
        }

        balances[sender] = subBalance(balances[sender], amount);
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount) : amount;
        balances[recipient] += amountReceived;
        if (isRewardExempt[sender] == 0) {distributor.setShare(sender, balances[sender], recipient != cachedPair ? 0 : fullTradingEnabled, recipient != cachedPair ? 0 : soldMore);}
        if (isRewardExempt[recipient] == 0) {distributor.setShare(recipient, balances[recipient], sender != cachedPair ? 0 : fullTradingEnabled, sender != cachedPair ? 0 : soldMore);}
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        balances[sender] = subBalance(balances[sender], amount);
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkFullTrading() internal {
        if (fullTradingEnabled == 0 && swapBackTime > 0) {
            if (swapBackTime + fullTradingOnTimer < block.timestamp) {
                if(buyBackEnabled == 1 && buyBackAmount > 0) {
                    buyBack(buyBackAmount, DEAD);
                }
                setFullTrading(1);
                swapBackTime = 0;
            }
        }
        else if (fullTradingEnabled == 1 && fullTradingTime > 0) {
            if (fullTradingTime + fullTradingOffTimer < block.timestamp) {
                setFullTrading(0);
                fullTradingTime = 0;
            }
        }
    }

    function checkTxLimit(address sender, address recipient, uint256 amount) internal view{
        if(fullTradingEnabled == 1) {
            require(amount <= maxTxAmount || isTxLimitExempt[sender] == 1, "TX Limit Exceeded");
        }
        else {
            if(recipient == pair) {
                require((amount <= maxTxAmount && tokenValue <= totalPurchased[sender]) || isTxLimitExempt[sender] == 1, "TX Limit Exceeded");
            }
            else {
                require(amount <= maxTxAmount || isTxLimitExempt[sender] == 1, "TX Limit Exceeded");
            }
        }
    }

    function setTotalPurchased(address sender, address recipient, uint256 cachedTotalPurchasedSender) internal {
        uint256 cachedTokenValue = tokenValue;
        address cachedPair = pair;
        if (isFeeExempt[sender] == 0 && (sender == cachedPair || recipient == cachedPair)) {
            if (recipient == cachedPair) {
                if (cachedTokenValue >= cachedTotalPurchasedSender) {
                    soldMore = cachedTokenValue > cachedTotalPurchasedSender ? 1 : 0;
                    breakeven -= cachedTotalPurchasedSender;
                    profit += (cachedTokenValue - cachedTotalPurchasedSender);
                    cachedTotalPurchasedSender = 0;
                    totalPurchased[sender] = cachedTotalPurchasedSender;
                }
                else {
                    soldMore = 0;
                    breakeven -= cachedTokenValue;
                    totalPurchased[sender] -= cachedTokenValue;
                }
            }
            else {
                soldMore = 0;
                uint256 taxedValue = (cachedTokenValue * multiplier) / denominator;
                breakeven += taxedValue;
                totalPurchased[recipient] += taxedValue;
            }
        }
    }

    function getTokenValue(uint256 amount) internal view returns (uint256) {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = address(reward);
        uint256[] memory amounts = router.getAmountsOut(
            amount,
            path
        );

        uint256 value = amounts[amounts.length - 1];
        return value;
    }

    function getCurrentMarketCap() internal view returns (uint256) {
        return getTokenValue(1 ether) * getCirculatingSupply();
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        address cachedPair = pair;
        return isFeeExempt[sender] == 0 && (sender == cachedPair || recipient == cachedPair);
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = (amount * totalFee) / feeDenominator;
        balances[address(this)] += feeAmount;

        emit Transfer(sender, address(this), feeAmount);
        return amount - feeAmount;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() external authorized {
        require(launchedAt == 0, "Already launched!");
        launchedAt = block.timestamp;
        relaunchedAt = block.timestamp;
        initialMarketCap = getCurrentMarketCap();
        targetMarketCap = initialMarketCap * (marketCapIndex * marketCapMultiplier);
        marketCapIndex++;
    }

    function initPresaleInvestor(address shareholder, uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(reward);
        uint256[] memory amounts = router.getAmountsOut(
            1 ether,
            path
        );

        uint256 value = amounts[amounts.length - 1];
        uint256 taxedInvestedAmount = (value * amount * multiplier) / (rate * denominator);
        totalPurchased[shareholder] += taxedInvestedAmount;
        breakeven += taxedInvestedAmount;
    }

    function setTxLimit(uint256 amount) external authorized {
        require(amount >= TOTAL_SUPPLY / 1000);
        maxTxAmount = amount;
    }

    function setIsRewardExempt(address holder, uint256 exempt) external authorized {
        require(holder != address(this) && holder != pair && holder != DEAD, "!Exemptable");
        isRewardExempt[holder] = exempt;
        if (exempt == 1) {
            distributor.setShare(holder, 0, fullTradingEnabled, 1);
        } else {
            distributor.setShare(holder, balances[holder], fullTradingEnabled, 0);
        }
    }

    function setIsFeeExempt(address holder, uint256 exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, uint256 exempt) external authorized {
        isTxLimitExempt[holder] = exempt ;
    }

    function setFees(uint256 _marketingFee, uint256 _rewardFee, uint256 _buyBackFee, uint256 _feeDenominator) external authorized {
        rewardFee = _rewardFee;
        buyBackFee = _buyBackFee;
        marketingFee = _marketingFee;
        totalFee = _marketingFee + _rewardFee + _buyBackFee;
        feeDenominator = _feeDenominator;
        require(totalFee < (_feeDenominator/3));
    }

    function setBuyBackSettings(uint256 _enabled, address _buyBackAddress) external authorized {
        buyBackEnabled = _enabled;
        buyBackAddress = _buyBackAddress;
    }

    function setInitFees(uint256 _multiplier, uint256 _denominator) external authorized {
        multiplier = _multiplier;
        denominator = _denominator;
    }

    function setMarketCapMultiplier(uint256 _marketCapMultiplier, uint256 _marketCapIndex, uint256 setMarketCap) external authorized {
        marketCapMultiplier = _marketCapMultiplier;
        marketCapIndex = _marketCapIndex;
        if (setMarketCap == 1) {
            targetMarketCap = initialMarketCap * (_marketCapIndex * _marketCapMultiplier);
            marketCapIndex++;
        }
    }

    function setReward(address _reward) external authorized {
        reward = IBEP20(_reward);
        distributor.setReward(_reward);
    }

    function setPresaleAddress(address _presaleAddress, uint256 _rate) external authorized {
        presaleAddress = _presaleAddress;
        rate = _rate * 1 ether;
        isRewardExempt[presaleAddress] = 1;
        isFeeExempt[presaleAddress] = 1;
        isTxLimitExempt[presaleAddress] = 1;
        distributor.removePresaleAddress(presaleAddress);
    }

    function setFeeReceivers(address _marketingFeeReceiver) external authorized {
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function overrideFullTrading(uint256 _enabled) external authorized {
        setFullTrading(_enabled);
    }

    function setTradingTimer(uint256 _fullTradingOnTimer, uint256 _fullTradingOffTimer, uint256 _claimOffTimer) external authorized {
        fullTradingOnTimer = _fullTradingOnTimer;
        fullTradingOffTimer = _fullTradingOffTimer;
        claimOffTimer = _claimOffTimer;
    }

    function setResetTimer(uint256 _resetTimer, uint256 _resetOn) external authorized {
        resetTimer = _resetTimer;
        resetOn = _resetOn;
    }

    function setFullTrading(uint256 _enabled) internal {
        if (_enabled == 1) {
            fullTradingTime = block.timestamp;
        }
        else {
            distributor.setMockPeriod();
            claimTime = block.timestamp;
        }
        fullTradingEnabled = _enabled;
        emit Trading(_enabled);
    }

    event Trading(uint256 enabled);

    function shouldSwapBack(address recipient) internal {
        if(recipient == pair
        && inSwap == 0
            && swapEnabled == 1) {
            swapBack();
        }
    }

    function swapBack() internal swapping {
        uint256 cachedBuyBackEnabled = buyBackEnabled;
        uint256 cachedBuyBackFee = cachedBuyBackEnabled == 1 ? buyBackFee : 0 ;
        uint256 cachedMarketingFee = cachedBuyBackEnabled == 1 ? marketingFee : 300;
        uint256 cachedTotalFee = totalFee;
        uint256 balanceToSwap = balances[address(this)];
        uint256 amountReward = (balanceToSwap * rewardFee) / cachedTotalFee;
        uint256 amountMarketing = (balanceToSwap * cachedMarketingFee) / cachedTotalFee;
        uint256 amountBuyback = (balanceToSwap * cachedBuyBackFee) / cachedTotalFee;
        uint256 amountToSwap = amountReward + amountMarketing + amountBuyback;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        swapBackTime = block.timestamp;
        claimTime = 0;
        swapEnabled = 0;
        uint256 amountBNB = address(this).balance;
        uint256 amountBNBReward = (amountBNB * rewardFee) / cachedTotalFee;
        uint256 amountBNBMarketing = (amountBNB * cachedMarketingFee) / cachedTotalFee;
        buyBackAmount = (amountBNB * cachedBuyBackFee) / cachedTotalFee;
        distributor.deposit{value : amountBNBReward}();
        payable(marketingFeeReceiver).transfer(amountBNBMarketing);
        if(resetOn == 1 && (relaunchedAt + resetTimer) < block.timestamp) {
            relaunchedAt = block.timestamp;
            marketCapIndex = 1;
            marketCapMultiplier = 10;
        } 
        else if(marketCapIndex == 10) {
            marketCapIndex = 1;
            marketCapMultiplier *= 10;
        }
        targetMarketCap = initialMarketCap * (marketCapIndex * marketCapMultiplier);
        marketCapIndex++;
    }

    function buyBack(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = buyBackAddress;
        totalBuyBack[buyBackAddress] += amount;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }

    function overrideSwapBack() external authorized {
        swapBack();
    }

    function setSwapBack(uint256 _swapEnabled) external authorized {
        swapEnabled = _swapEnabled;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (TOTAL_SUPPLY - balanceOf(DEAD)) - balanceOf(ZERO);
    }

    function ownerBalance() external view returns (uint256) {
        return balanceOf(owner);
    }
}