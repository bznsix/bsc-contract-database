// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface AntiSnipe {
    function checkUser(address from, address to, uint256 amt) external returns (bool);
    function setLaunch(address _initialLpPair, uint32 _liqAddBlock, uint64 _liqAddStamp, uint8 dec) external;
    function setLpPair(address pair, bool enabled) external;
    function setProtections(bool _as, bool _ag, bool _ab, bool _algo) external;
    function setGasPriceLimit(uint256 gas) external;
    function removeSniper(address account) external;
    function getSniperAmt() external view returns (uint256);
    function removeBlacklisted(address account) external;
    function isBlacklisted(address account) external view returns (bool);
}

interface Cashier {
    function whomst() external view returns(address);
    function whomst_router() external view returns (address);
    function whomst_token() external view returns (address);
    function setToken(address token) external;
    function setReflectionCriteria(uint256 _minPeriod, uint256 _minReflection) external;
    function tally(address shareholder, uint256 amount) external;
    function load() external payable;
    function cashout(uint256 gas) external;
    function giveMeWelfarePlease(address hobo) external;
    function getTotalDistributed() external view returns(uint256);
    function getShareholderInfo(address shareholder) external view returns(string memory, string memory, string memory, string memory);
    function getShareholderRealized(address shareholder) external view returns (uint256);
    function getPendingRewards(address shareholder) external view returns (uint256);
    function initialize() external;
}

contract WaterTigerInu is IERC20 {
    // Ownership moved to in-contract for customizability.
    address private _owner;

    mapping (address => uint256) _tOwned;
    mapping (address => bool) lpPairs;
    uint256 private timeSinceLastPair = 0;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcludedFromLimits;
    mapping (address => bool) private _isExcludedFromDividends;
    mapping (address => bool) private _liquidityHolders;

    uint256 constant private startingSupply = 1_000_000_000_000;

    string constant private _name = "WaterTigerInu";
    string constant private _symbol = "WTI";
    uint8 constant private _decimals = 9;

    uint256 private _tTotal = startingSupply * (10 ** _decimals);

    struct Fees {
        uint16 buyFee;
        uint16 sellFee;
        uint16 transferFee;
    }

    struct Ratios {
        uint16 rewards;
        uint16 liquidity;
        uint16 marketing;
        uint16 buyback;
        uint16 dev1;
        uint16 dev2;
        uint16 dev3;
        uint16 total;
    }

    Fees public _taxRates = Fees({
        buyFee: 1200,
        sellFee: 1500,
        transferFee: 1300
        });

    Ratios public _ratios = Ratios({
        rewards: 3,
        liquidity: 6,
        marketing: 6,
        buyback: 6,
        dev1: 2,
        dev2: 2,
        dev3: 2,
        total: 27
        });

    uint256 constant public maxBuyTaxes = 2000;
    uint256 constant public maxSellTaxes = 2000;
    uint256 constant public maxTransferTaxes = 2000;
    uint256 constant masterTaxDivisor = 10000;

    IRouter02 public dexRouter;
    address public lpPair;

    // SHIBA INU MAINNET TOKEN CONTRACT ADDRESS
    address constant public SHIBA = 0x2859e4544C4bB03966803b044A93563Bd2D0DD4D;

    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant private ZERO = 0x0000000000000000000000000000000000000000;

    address payable public _marketingWallet;
    address payable public _buybackWallet;
    address payable public _dev1Wallet;
    address payable public _dev2Wallet;
    address payable private _dev3Wallet;

    uint256 private _maxTxAmount = (_tTotal * 5) / 1000;
    uint256 private _maxWalletSize = (_tTotal * 2) / 100;

    Cashier reflector;
    uint256 reflectorGas = 300000;

    bool inSwap;
    bool public contractSwapEnabled = false;
    uint256 public contractSwapTimer = 10 seconds;
    uint256 private lastSwap;
    uint256 public swapThreshold = (_tTotal * 5) / 10000;
    uint256 public swapAmount = (_tTotal * 20) / 10000;
    bool public processReflect = false;

    bool public tradingEnabled = false;
    bool public _hasLiqBeenAdded = false;
    AntiSnipe antiSnipe;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ContractSwapEnabledUpdated(bool enabled);
    event AutoLiquify(uint256 amountBNB, uint256 amount);
    event SniperCaught(address sniperAddress);

    constructor () payable {
        _tOwned[msg.sender] = _tTotal;

        // Set the owner.
        _owner = msg.sender;

        if (block.chainid == 56) {
            dexRouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            contractSwapTimer = 3 seconds;
        } else if (block.chainid == 97) {
            dexRouter = IRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
            contractSwapTimer = 3 seconds;
        } else if (block.chainid == 1 || block.chainid == 4) {
            dexRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
            contractSwapTimer = 10 seconds;
        } else {
            revert();
        }

        lpPair = IFactoryV2(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        lpPairs[lpPair] = true;

        _approve(msg.sender, address(dexRouter), type(uint256).max);
        _approve(address(this), address(dexRouter), type(uint256).max);

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromDividends[owner()] = true;
        _isExcludedFromDividends[lpPair] = true;
        _isExcludedFromDividends[address(this)] = true;
        _isExcludedFromDividends[DEAD] = true;
        _isExcludedFromDividends[ZERO] = true;

        emit Transfer(ZERO, msg.sender, _tTotal);
        emit OwnershipTransferred(address(0), _owner);
    }

//===============================================================================================================
//===============================================================================================================
//===============================================================================================================
    // Ownable removed as a lib and added here to allow for custom transfers and renouncements.
    // This allows for removal of ownership privileges from the owner once renounced or transferred.
    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != DEAD, "Call renounceOwnership to transfer owner to the zero address.");
        _isExcludedFromFees[_owner] = false;
        _isExcludedFromDividends[_owner] = false;
        _isExcludedFromFees[newOwner] = true;
        _isExcludedFromDividends[newOwner] = true;
        
        if(_tOwned[_owner] > 0) {
            _transfer(_owner, newOwner, _tOwned[_owner]);
        }
        
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
        
    }

    function renounceOwnership() public virtual onlyOwner {
        _isExcludedFromFees[_owner] = false;
        _isExcludedFromDividends[_owner] = false;
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }
//===============================================================================================================
//===============================================================================================================
//===============================================================================================================

    receive() external payable {}

    function totalSupply() external view override returns (uint256) { if (_tTotal == 0) { revert(); } return _tTotal; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner(); }
    function balanceOf(address account) public view override returns (uint256) { return _tOwned[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) private {
        require(sender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function approveContractContingency() public onlyOwner returns (bool) {
        _approve(address(this), address(dexRouter), type(uint256).max);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transfer(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function isBlacklisted(address account) public view returns (bool) {
        return antiSnipe.isBlacklisted(account);
    }

    function setInitializers(address aInitializer, address cInitializer) external onlyOwner {
        require(cInitializer != address(this) && aInitializer != address(this) && cInitializer != aInitializer);
        reflector = Cashier(cInitializer);
        antiSnipe = AntiSnipe(aInitializer);
    }

    function removeSniper(address account) external onlyOwner() {
        antiSnipe.removeSniper(account);
    }

    function removeBlacklisted(address account) external onlyOwner() {
        antiSnipe.removeBlacklisted(account);
    }

    function getSniperAmt() public view returns (uint256) {
        return antiSnipe.getSniperAmt();
    }

    function setProtectionSettings(bool _antiSnipe, bool _antiGas, bool _antiBlock, bool _antiSpecial) external onlyOwner() {
        antiSnipe.setProtections(_antiSnipe, _antiGas, _antiBlock, _antiSpecial);
    }

    function setGasPriceLimit(uint256 gas) external onlyOwner {
        require(gas >= 75, "Too low.");
        antiSnipe.setGasPriceLimit(gas);
    }

    function enableTrading() public onlyOwner {
        require(!tradingEnabled, "Trading already enabled!");
        require(_hasLiqBeenAdded, "Liquidity must be added.");
        if(address(antiSnipe) == address(0)){
            antiSnipe = AntiSnipe(address(this));
        }
        try antiSnipe.setLaunch(lpPair, uint32(block.number), uint64(block.timestamp), _decimals) {} catch {}
        tradingEnabled = true;
        processReflect = true;
    }

    function setTaxes(uint16 buyFee, uint16 sellFee, uint16 transferFee) external onlyOwner {
        require(buyFee <= maxBuyTaxes
                && sellFee <= maxSellTaxes
                && transferFee <= maxTransferTaxes);
        _taxRates.buyFee = buyFee;
        _taxRates.sellFee = sellFee;
        _taxRates.transferFee = transferFee;
    }

    function setRatios(uint16 rewards, uint16 liquidity, uint16 marketing, uint16 buyback, uint16 dev1, uint16 dev2, uint16 dev3) external onlyOwner {
        if(dev1 > 0 || dev2 > 0) {
            if (dev1 > dev2) {
                require(dev3 == dev1);
            } else {
                require(dev3 == dev2);
            }
        }
        _ratios.rewards = rewards;
        _ratios.liquidity = liquidity;
        _ratios.marketing = marketing;
        _ratios.buyback = buyback;
        _ratios.dev1 = dev1;
        _ratios.dev2 = dev2;
        _ratios.dev3 = dev3;
        _ratios.total = rewards + liquidity + marketing + buyback + dev1 + dev2 + dev3;
    }

    function setWallets(address payable marketing, address payable buyback, address payable dev1, address payable dev2, address payable dev3) external onlyOwner {
        _marketingWallet = payable(marketing);
        _buybackWallet = payable(buyback);
        _dev1Wallet = payable(dev1);
        _dev2Wallet = payable(dev2);
        if(address(_dev3Wallet) == address(0)) {
            _dev3Wallet = payable(dev3);
        }
    }

    function setContractSwapSettings(bool _enabled, bool processReflectEnabled) external onlyOwner {
        contractSwapEnabled = _enabled;
        processReflect = processReflectEnabled;
    }

    function setSwapSettings(uint256 thresholdPercent, uint256 thresholdDivisor, uint256 amountPercent, uint256 amountDivisor, uint256 time) external onlyOwner {
        swapThreshold = (_tTotal * thresholdPercent) / thresholdDivisor;
        swapAmount = (_tTotal * amountPercent) / amountDivisor;
        contractSwapTimer = time;
    }

    function setReflectionCriteria(uint256 _minPeriod, uint256 _minReflection, uint256 minReflectionMultiplier) external onlyOwner {
        _minReflection = _minReflection * 10**minReflectionMultiplier;
        reflector.setReflectionCriteria(_minPeriod, _minReflection);
    }

    function setReflectorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        reflectorGas = gas;
    }

    function giveMeWelfarePlease() external {
        reflector.giveMeWelfarePlease(msg.sender);
    }

    function getTotalReflected() external view returns (uint256) {
        return reflector.getTotalDistributed();
    }

    function getUserInfo(address shareholder) external view returns (string memory, string memory, string memory, string memory) {
        return reflector.getShareholderInfo(shareholder);
    }

    function getUserRealizedGains(address shareholder) external view returns (uint256) {
        return reflector.getShareholderRealized(shareholder);
    }

    function getUserUnpaidEarnings(address shareholder) external view returns (uint256) {
        return reflector.getPendingRewards(shareholder);
    }

    function setNewRouter(address newRouter) public onlyOwner() {
        IRouter02 _newRouter = IRouter02(newRouter);
        address get_pair = IFactoryV2(_newRouter.factory()).getPair(address(this), _newRouter.WETH());
        if (get_pair == address(0)) {
            lpPair = IFactoryV2(_newRouter.factory()).createPair(address(this), _newRouter.WETH());
        }
        else {
            lpPair = get_pair;
        }
        dexRouter = _newRouter;
        _approve(address(this), address(dexRouter), type(uint256).max);
    }

    function setLpPair(address pair, bool enabled) external onlyOwner {
        if (enabled == false) {
            lpPairs[pair] = false;
            antiSnipe.setLpPair(pair, false);
        } else {
            if (timeSinceLastPair != 0) {
                require(block.timestamp - timeSinceLastPair > 3 days, "Cannot set a new pair this week!");
            }
            lpPairs[pair] = true;
            timeSinceLastPair = block.timestamp;
            antiSnipe.setLpPair(pair, true);
        }
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function isExcludedFromDividends(address account) public view returns(bool) {
        return _isExcludedFromDividends[account];
    }

    function isExcludedFromLimits(address account) public view returns (bool) {
        return _isExcludedFromLimits[account];
    }

    function setExcludedFromLimits(address account, bool enabled) external onlyOwner {
        _isExcludedFromLimits[account] = enabled;
    }

    function setDividendExcluded(address holder, bool enabled) public onlyOwner {
        require(holder != address(this) && holder != lpPair);
        _isExcludedFromDividends[holder] = enabled;
        if (enabled) {
            reflector.tally(holder, 0);
        } else {
            reflector.tally(holder, _tOwned[holder]);
        }
    }

    function setExcludedFromFees(address account, bool enabled) public onlyOwner {
        _isExcludedFromFees[account] = enabled;
    }

    function setMaxTxPercent(uint256 percent, uint256 divisor) external onlyOwner {
        require((_tTotal * percent) / divisor >= (_tTotal / 1000), "Max Transaction amt must be above 0.1% of total supply.");
        _maxTxAmount = (_tTotal * percent) / divisor;
    }

    function setMaxWalletSize(uint256 percent, uint256 divisor) external onlyOwner {
        require((_tTotal * percent) / divisor >= (_tTotal / 1000), "Max Wallet amt must be above 0.1% of total supply.");
        _maxWalletSize = (_tTotal * percent) / divisor;
    }

    function getMaxTX() public view returns (uint256) {
        return _maxTxAmount / (10**_decimals);
    }

    function getMaxWallet() public view returns (uint256) {
        return _maxWalletSize / (10**_decimals);
    }

    function _hasLimits(address from, address to) private view returns (bool) {
        return from != owner()
            && to != owner()
            && tx.origin != owner()
            && !_liquidityHolders[to]
            && !_liquidityHolders[from]
            && to != DEAD
            && to != address(0)
            && from != address(this);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(_hasLimits(from, to)) {
            if(!tradingEnabled) {
                revert("Trading not yet enabled!");
            }
            if(lpPairs[from] || lpPairs[to]){
                if (!_isExcludedFromLimits[from] && !_isExcludedFromLimits[to]) {
                    require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
                }
            }
            if(to != address(dexRouter) && !lpPairs[to]) {
                if (!_isExcludedFromLimits[to]) {
                    require(balanceOf(to) + amount <= _maxWalletSize, "Transfer amount exceeds the maxWalletSize.");
                }
            }
        }

        bool takeFee = true;
        
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]){
            takeFee = false;
        }

        return _finalizeTransfer(from, to, amount, takeFee);
    }

    function _finalizeTransfer(address from, address to, uint256 amount, bool takeFee) internal returns (bool) {
        if (!_hasLiqBeenAdded) {
            _checkLiquidityAdd(from, to);
            if (!_hasLiqBeenAdded && _hasLimits(from, to)) {
                revert("Only owner can transfer at this time.");
            }
        }

        if(_hasLimits(from, to)) {
            bool checked;
            try antiSnipe.checkUser(from, to, amount) returns (bool check) {
                checked = check;
            } catch {
                revert();
            }

            if(!checked) {
                revert();
            }
        }

        if (inSwap) {
            return _basicTransfer(from, to, amount);
        } else {
            _tOwned[from] -= amount;
        }

        if (lpPairs[to]) {
            if (!inSwap
                && contractSwapEnabled
            ) {
                if (lastSwap + contractSwapTimer < block.timestamp) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance >= swapThreshold) {
                        if(contractTokenBalance >= swapAmount) { contractTokenBalance = swapAmount; }
                        contractSwap(contractTokenBalance);
                        lastSwap = block.timestamp;
                    }
                }
            }      
        } 

        uint256 amountReceived = amount;

        if (takeFee) {
            amountReceived = takeTaxes(from, to, amount);
        }

        _tOwned[to] += amountReceived;

        processTokenReflect(from, to);

        emit Transfer(from, to, amountReceived);
        return true;
    }

    function processTokenReflect(address from, address to) internal {
        if (!_isExcludedFromDividends[from]) {
            try reflector.tally(from, _tOwned[from]) {} catch {}
        }
        if (!_isExcludedFromDividends[to]) {
            try reflector.tally(to, _tOwned[to]) {} catch {}
        }
        if (processReflect) {
            try reflector.cashout(reflectorGas) {} catch {}
        }
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
        _tOwned[from] -= amount;
        _tOwned[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function takeTaxes(address from, address to, uint256 amount) internal returns (uint256) {
        uint256 currentFee;
        if (lpPairs[from]) {
            currentFee = _taxRates.buyFee;
        } else if (lpPairs[to]) {
            currentFee = _taxRates.sellFee;
        } else {
            currentFee = _taxRates.transferFee;
        }

        if (currentFee == 0) {
            return amount;
        }

        uint256 feeAmount = amount * currentFee / masterTaxDivisor;

        _tOwned[address(this)] += feeAmount;
        emit Transfer(from, address(this), feeAmount);

        return amount - feeAmount;
    }

    function contractSwap(uint256 contractTokenBalance) internal swapping {
        Ratios memory ratios = _ratios;
        if (ratios.total == 0) {
            return;
        }
        
        if(_allowances[address(this)][address(dexRouter)] != type(uint256).max) {
            _allowances[address(this)][address(dexRouter)] = type(uint256).max;
        }

        uint256 toLiquify = ((contractTokenBalance * ratios.liquidity) / (ratios.total)) / 2;
        uint256 swapAmt = contractTokenBalance - toLiquify;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            swapAmt,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amtBalance = address(this).balance;
        uint256 liquidityBalance = (amtBalance * toLiquify) / swapAmt;

        if (toLiquify > 0) {
            dexRouter.addLiquidityETH{value: liquidityBalance}(
                address(this),
                toLiquify,
                0,
                0,
                DEAD,
                block.timestamp
            );
            emit AutoLiquify(liquidityBalance, toLiquify);
        }

        amtBalance -= liquidityBalance;
        ratios.total -= ratios.liquidity;
        uint256 rewardsBalance = (amtBalance * ratios.rewards) / ratios.total;
        uint256 buybackBalance = (amtBalance * ratios.buyback) / ratios.total;
        uint256 dev1Balance = (amtBalance * ratios.dev1) / ratios.total;
        uint256 dev2Balance = (amtBalance * ratios.dev2) / ratios.total;
        uint256 dev3Balance = (amtBalance * ratios.dev3) / ratios.total;
        uint256 marketingBalance = amtBalance - (rewardsBalance + buybackBalance + dev1Balance + dev2Balance + dev3Balance);

        try reflector.load{value: rewardsBalance}() {} catch {}

        if(ratios.marketing > 0){
            _marketingWallet.transfer(marketingBalance);
        }
        if(ratios.buyback > 0){
            _buybackWallet.transfer(buybackBalance);
        }
        if(ratios.dev1 > 0){
            _dev1Wallet.transfer(dev1Balance);
        }
        if(ratios.dev2 > 0){
            _dev2Wallet.transfer(dev2Balance);
        }
        if(ratios.dev3 > 0){
            _dev3Wallet.transfer(dev3Balance);
        }
    }

    function manualDeposit() external onlyOwner {
        try reflector.load{value: address(this).balance}() {} catch {}
    }

    function _checkLiquidityAdd(address from, address to) private {
        require(!_hasLiqBeenAdded, "Liquidity already added and marked.");
        if (!_hasLimits(from, to) && to == lpPair) {
            _liquidityHolders[from] = true;
            _hasLiqBeenAdded = true;
            if(address(antiSnipe) == address(0)) {
                antiSnipe = AntiSnipe(address(this));
            }
            if(address(reflector) ==  address(0)) {
                reflector = Cashier(address(this));
            }
            try reflector.initialize() {} catch {}
            contractSwapEnabled = true;
            emit ContractSwapEnabledUpdated(true);
        }
    }

    function multiSendTokens(address[] memory accounts, uint256[] memory amounts) external {
        require(accounts.length == amounts.length, "Lengths do not match.");
        for (uint8 i = 0; i < accounts.length; i++) {
            require(balanceOf(msg.sender) >= amounts[i]);
            _transfer(msg.sender, accounts[i], amounts[i]*10**_decimals);
        }
    }

    function multiSendPercents(address[] memory accounts, uint256[] memory percents, uint256[] memory divisors) external {
        require(accounts.length == percents.length && percents.length == divisors.length, "Lengths do not match.");
        for (uint8 i = 0; i < accounts.length; i++) {
            require(balanceOf(msg.sender) >= (_tTotal * percents[i]) / divisors[i]);
            _transfer(msg.sender, accounts[i], (_tTotal * percents[i]) / divisors[i]);
        }
    }
}