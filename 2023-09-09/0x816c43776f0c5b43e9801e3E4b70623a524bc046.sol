// SPDX-License-Identifier: MIT

/*
Connect. Transact. Evolve. Welcome to The Web.

TG: https://t.me/QWebOfficial

                                            .:                                            
                                          .*#*#:                                          
                                        .*#:  .*#:                                        
                                      .*#:      .*#:                                      
                                    .*#:          .*#:                                    
                                   *#:              .*#:                                  
                                 +#:                  .*#:                                
                              .+#:                      .*#:                              
                            .*#:                          .+#-                            
                          .*#:                              .+#:                          
                         :@=                                  :@+                         
                     .    :**.                               +#-    .                     
                   :###-    :**.                           +%-    .*#%=                   
                 :#*.  +#-    :**.         :#%-          +#-    .**:  =#-                 
               :#*.      +#:    :**.     :#*. +%-      +#-    .**:      +#-               
             :#*.         .*#:    :#*. :#*.     +%-  +#-    .**.          +#-             
           :#*.             .+#-    :%%#.         +%%-    .**:              =#=           
         -#+.                  +#- -#+:*#:      .+#:=#= :#*.                  =#=         
       :#+.                      #@#    .*#:  .+#:    *@@.                      =%=       
     :#*.                      :#+.+#-    .**+#:    .#*:=#-                       =%=     
   :#*.                      :#+.    +#-    ::    .**.    =#-                       =%=   
  ##.                       ##.        #%.       *%:        *%.                       +%: 
  .*#:                      .*#:     :**.   .:    +#-     .*#:                      .*#:  
    .*#:                      .*#: :**.    +#**:    +#: .*#:                      .*#:    
      .**:                      .#%#.    +#:  .**:   .#%%:                      .*#:      
        .**:                   :**:**:.+#:      .+*:.**:+#-                   .+*:        
          .+#:               :#*.   :@@=          :@@=    =#-               .*#:          
            .+#:           :#*.   .**:.+#:      .**:.*#:    =#-           .*#:            
              .+#:       :#*.   .*#:    .+#:  .**:    .*#:    +#-       .*#:              
                .*#:   :**.   .*#:        .+#**:        .*#:    +#-   .*#:                
                  .*#-**.   .*#:            .:            .*#:    +#-*#:                  
                    .+.   .*#:                              .**:    =:                    
                         :@-                                  :@+                         
                          :#*.                               =#-                          
                            :**:                           +#-                            
                              .*#:                      .+#-                              
                                .*#.                  .+#-                                
                                  .**.               +#-                                  
                                    .**.           +#:                                    
                                      .**.       +#-                                      
                                        .**.   +#-                                        
                                          .**+#-                                          
                                            :-                                            
*/

pragma solidity ^0.8.6;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
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
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

interface DividendPayingTokenInterface {

  function dividendOf(address _owner) external view returns(uint256);
  function withdrawDividend() external;
  function withdrawableDividendOf(address _owner) external view returns(uint256);
  function withdrawnDividendOf(address _owner) external view returns(uint256);
  function accumulativeDividendOf(address _owner) external view returns(uint256);
  event DividendsDistributed(
    address indexed from,
    uint256 weiAmount
  );

  event DividendWithdrawn(
    address indexed to,
    uint256 weiAmount
  );
  
}

interface IPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapRouter {
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
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}

contract DividendPayingToken is ERC20, DividendPayingTokenInterface, Ownable {

    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    address public LP_Token;

    uint256 constant internal magnitude = 2**128;

    uint256 internal magnifiedDividendPerShare;

    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    uint256 public totalDividendsDistributed;
    uint256 public totalDividendsWithdrawn;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function distributeLPDividends(uint256 amount) public onlyOwner {
        require(totalSupply() > 0);

        if (amount > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add((amount).mul(magnitude) / totalSupply());
            emit DividendsDistributed(msg.sender, amount);

            totalDividendsDistributed = totalDividendsDistributed.add(amount);
        }
    }

    function withdrawDividend() public virtual override {
        _withdrawDividendOfUser(payable(msg.sender));
    }

    function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
            totalDividendsWithdrawn += _withdrawableDividend;
            emit DividendWithdrawn(user, _withdrawableDividend);
            bool success = IERC20(LP_Token).transfer(user, _withdrawableDividend);

            if(!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
                totalDividendsWithdrawn -= _withdrawableDividend;
                return 0;
            }

            return _withdrawableDividend;
        }

        return 0;
    }


    function dividendOf(address _owner) public view override returns(uint256) {
        return withdrawableDividendOf(_owner);
    }


    function withdrawableDividendOf(address _owner) public view override returns(uint256) {
        return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
    }

    function withdrawnDividendOf(address _owner) public view override returns(uint256) {
        return withdrawnDividends[_owner];
    }

    function accumulativeDividendOf(address _owner) public view override returns(uint256) {
        return magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe()
                .add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
    }

    function _transfer(address from, address to, uint256 value) internal virtual override {
        require(false);

        int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
        magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
        magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
    }

    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
        .sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
    }

    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
        .add( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);

        if(newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if(newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }
}

// If anyone gets the reference you score bonus points
contract QuantumsWeb is ERC20, Ownable {
    IUniswapRouter public router;
    address public pair;

    bool private swapping;
    bool public swapEnabled = true;
    bool public claimEnabled;
    bool public tradingEnabled;

    QWEBDividendTracker public dividendTracker;

    address public devWallet;
    address public taxMan;
    address public taxKing;

    uint256 public swapTokensAtAmount;
    uint256 public maxBuyAmount;
    uint256 public maxSellAmount;
    uint256 public maxWallet;
    uint256 public taxManBuyAmount;
    uint256 public taxKingBuyAmount;
    uint256 public taxManBuyThreshold = 500000 * (10**18);
    uint256 public taxManDuration = 1 hours;
    uint256 public taxKingDuration = 24 hours;
    uint256 public lastTaxManSetTime;
    uint256 public lastTaxKingSetTime;

    // Taxes represented in promille form (denominator of 1000)
    struct Taxes {
        uint256 liquidity;
        uint256 dev;
        uint256 taxMan;
        uint256 taxKing;
    }

    Taxes public buyTaxes = Taxes(20, 20, 0, 0);
    Taxes public sellTaxes = Taxes(20, 20, 0, 0);

    uint256 public totalBuyTax = 40;
    uint256 public totalSellTax = 40;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) private _isExcludedFromMaxWallet;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event GasForProcessingUpdated(
        uint256 indexed newValue,
        uint256 indexed oldValue
    );
    event SendDividends(uint256 tokensSwapped, uint256 amount);
    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );
    event NewTaxMan(address indexed taxMan, uint256 buyAmount);
    event NewTaxKing(address indexed taxKing, uint256 buyAmount);




    // fuck you @EpsteinRektLaunches
    //      - QWEB Team



    constructor(address _developerwallet) ERC20("Quantums Web", "QWEB") {
        dividendTracker = new QWEBDividendTracker();
        setDevWallet(_developerwallet);

        IUniswapRouter _router = IUniswapRouter(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506); // Sushi
        address _pair = IFactory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );

        router = _router;
        pair = _pair;
        setSwapTokensAtAmount(300000); 
        updateMaxWalletAmount(2000000);
        setMaxBuyAndSell(1000000, 1000000);

        _setAutomatedMarketMakerPair(_pair, true);

        dividendTracker.updateLP_Token(pair);

        dividendTracker.excludeFromDividends(address(dividendTracker), true);
        dividendTracker.excludeFromDividends(address(this), true);
        dividendTracker.excludeFromDividends(owner(), true);
        dividendTracker.excludeFromDividends(address(0xdead), true);
        dividendTracker.excludeFromDividends(address(_router), true);

        excludeFromMaxWallet(address(_pair), true);
        excludeFromMaxWallet(address(this), true);
        excludeFromMaxWallet(address(_router), true);

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);

        _mint(owner(), 100000000 * (10**18));
    }

    receive() external payable {}

    function updateDividendTracker(address newAddress) public onlyOwner {
        QWEBDividendTracker newDividendTracker = QWEBDividendTracker(
            payable(newAddress)
        );
        newDividendTracker.excludeFromDividends(
            address(newDividendTracker),
            true
        );
        newDividendTracker.excludeFromDividends(address(this), true);
        newDividendTracker.excludeFromDividends(owner(), true);
        newDividendTracker.excludeFromDividends(address(router), true);
        dividendTracker = newDividendTracker;
    }

    function claim() external {
        require(claimEnabled, "Claim not enabled");
        dividendTracker.processAccount(payable(msg.sender));
    }

    function updateMaxWalletAmount(uint256 newNum) public onlyOwner {
        require(newNum >= 1000000, "Cannot set maxWallet lower than 1%");
        maxWallet = newNum * 10**18;
    }

    function setMaxBuyAndSell(uint256 maxBuy, uint256 maxSell) public onlyOwner {
        require(maxBuy >= 1000000, "Cannot set maxbuy lower than 1% ");
        require(maxSell >= 1000000, "Cannot set maxsell lower than 1% ");
        maxBuyAmount = maxBuy * 10**18;
        maxSellAmount = maxSell * 10**18;
    }

    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount * 10**18;
    }

    function excludeFromMaxWallet(address account, bool excluded) public onlyOwner {
        _isExcludedFromMaxWallet[account] = excluded;
    }

    function rescueERC20TokensInFull(address tokenAddress) external onlyOwner {
        IERC20(tokenAddress).transfer(owner(),IERC20(tokenAddress).balanceOf(address(this)));
    }

    function rescueERC20TokensByAmount(address tokenAddress, uint256 amount) external onlyOwner{
        IERC20(tokenAddress).transfer(owner(), amount);
    }

    function forceSend() external onlyOwner {
        uint256 ETHbalance = address(this).balance;
        (bool success, ) = payable(devWallet).call{value: ETHbalance}("");
        require(success);
    }

    function trackerRescueETH20Tokens(address tokenAddress) external onlyOwner {
        dividendTracker.trackerRescueETH20Tokens(msg.sender, tokenAddress);
    }

    function updateRouter(address newRouter) external onlyOwner {
        router = IUniswapRouter(newRouter);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(
            _isExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeFromDividends(address account, bool value) public onlyOwner {
        dividendTracker.excludeFromDividends(account, value);
    }

    function setDevWallet(address newWallet) public onlyOwner {
        devWallet = newWallet;
    }

    function setTaxManBuyThreshold(uint256 amount) public onlyOwner {
        taxManBuyThreshold = amount;
    }

    function setBuyTaxes(uint256 _liquidity, uint256 _dev, uint256 _taxMan, uint256 _taxKing) external onlyOwner {
        require(_liquidity + _dev <= 100, "Fee must be <= 10%"); // promille
        buyTaxes = Taxes(_liquidity, _dev, _taxMan, _taxKing);
        totalBuyTax = _liquidity + _dev;
    }

    function setSellTaxes(uint256 _liquidity, uint256 _dev, uint256 _taxMan, uint256 _taxKing) external onlyOwner {
        require(_liquidity + _dev <= 100, "Fee must be <= 10%"); // promille
        sellTaxes = Taxes(_liquidity, _dev, _taxMan, _taxKing);
        totalSellTax = _liquidity + _dev;
    }

    function setTaxManDuration(uint256 _newDuration) external onlyOwner {
        taxManDuration = _newDuration;
    }

    function setTaxKingDuration(uint256 _newDuration) external onlyOwner {
        taxKingDuration = _newDuration;
    }

    function setSwapEnabled(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
    }

    function activateTrading() external onlyOwner {
        require(!tradingEnabled, "Trading already enabled");
        tradingEnabled = true;
    }

    function setClaimEnabled(bool state) external onlyOwner {
        claimEnabled = state;
    }

    function setLP_Token(address _lpToken) external onlyOwner {
        dividendTracker.updateLP_Token(_lpToken);
    }

    function setAutomatedMarketMakerPair(address newPair, bool value) external onlyOwner {
        _setAutomatedMarketMakerPair(newPair, value);
    }

    function _setAutomatedMarketMakerPair(address newPair, bool value) private {
        require(
            automatedMarketMakerPairs[newPair] != value,
            "Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[newPair] = value;

        if (value) {
            dividendTracker.excludeFromDividends(newPair, true);
        }

        emit SetAutomatedMarketMakerPair(newPair, value);
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account) public view returns (uint256) {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }

    function getAccountInfo(address account) external view returns (address, uint256, uint256, uint256, uint256) {
        return dividendTracker.getAccount(account);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to] && !swapping) { // If ur not WL for trading
            require(tradingEnabled, "Trading not active"); // U can't trade unless trading is active
            if (automatedMarketMakerPairs[to]) { // If you're selling
                require(amount <= maxSellAmount, "You are exceeding maxSellAmount"); // Can't sell too much
            } else if (automatedMarketMakerPairs[from]) // If you're buying
                require(amount <= maxBuyAmount, "You are exceeding maxBuyAmount"); // Can't buy too much
            if (!_isExcludedFromMaxWallet[to]) { // If you aren't WL for max wallet
                require(amount + balanceOf(to) <= maxWallet, "Unable to exceed Max Wallet"); // Can't go over max wallet
            }
        }

        if (amount == 0) { // If you're not doing anything
            super._transfer(from, to, 0); // Do pretty much nothing lol
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this)); // How many tokens are in the ca
        bool canSwap = contractTokenBalance >= swapTokensAtAmount; // Contract can sell if it's over the threshold

        if ( // IF
            canSwap && // CA over threshold
            !swapping && // A swap is not active
            swapEnabled && // You can swap
            automatedMarketMakerPairs[to] && // You are selling
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true; // We are now swapping

            if (totalSellTax > 0) { // If we got tax
                swapAndLiquify(swapTokensAtAmount); // Tax em
            }

            swapping = false;
        }

        bool takeFee = !swapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) { 
            takeFee = false;
        }

        if (!automatedMarketMakerPairs[to] && !automatedMarketMakerPairs[from]) // If it's a normal xfer
            takeFee = false; // You good

        if (takeFee) { // If you're getting taxed
            uint256 feeAmt = automatedMarketMakerPairs[to] ? (amount * totalSellTax) / 1000 : (amount * totalBuyTax) / 1000;
            amount = amount - feeAmt; // Take away the taxed amount of tokens
            super._transfer(from, address(this), feeAmt); // Give your taxes to the CA
        }
        super._transfer(from, to, amount); // Give you the rest

        if (automatedMarketMakerPairs[to] && (from == taxMan || from == taxKing)) { // If taxMan or taxKing selling
            if (from == taxMan) {
                taxMan = devWallet; // Reset taxMan to developer wallet
                taxManBuyAmount = 0; // Reset the amount needed to beat to become taxMan
                lastTaxManSetTime = block.timestamp; // Reset timestamp so not being set every time
            }
            if (from == taxKing) {
                taxKing = devWallet; // Reset taxKing to developer wallet
                taxKingBuyAmount = 0; // Reset the amount needed to beat to become taxKing
                lastTaxKingSetTime = block.timestamp; // Reset timestamp so not being set every time
            }
        }

        // Not the most efficient but it works okay
        bool isNewTaxMan = false;
        bool isNewTaxKing = false;

        if (automatedMarketMakerPairs[from] && !_isExcludedFromFees[to]) { // If you're buying and not excluded
            if (amount >= taxManBuyThreshold && amount > taxManBuyAmount) { // If it's over the threshold and more than prev. taxMan
                taxMan = to; // You are the taxMan!!
                lastTaxManSetTime = block.timestamp; // Update timestamp
                taxManBuyAmount = amount; // Set the new amount to beat
                isNewTaxMan = true; // We got a taxman
                emit NewTaxMan(taxMan, amount);
            }
            if (amount >= taxManBuyThreshold && amount > taxKingBuyAmount) { // If it's over the threshold and more than prev. taxKing
                taxKing = to; // You are the taxKing!!
                lastTaxKingSetTime = block.timestamp; // Update timestamp
                taxKingBuyAmount = amount; // Set the new amount to beat
                isNewTaxKing = true; // We got a taxKing
                emit NewTaxKing(taxKing, amount);
            }
        }

        if (!isNewTaxMan && block.timestamp > lastTaxManSetTime + taxManDuration) { // If no new taxMan and time has expired
            taxMan = devWallet; // I am now the taxMan!
            lastTaxManSetTime = block.timestamp; // Update timestamp
            taxManBuyAmount = 0; // Reset amount to beat
        }

        if (!isNewTaxKing && block.timestamp > lastTaxKingSetTime + taxKingDuration) { // If no new taxKing and time has expired
            taxKing = devWallet; // I am now the taxKing!
            lastTaxManSetTime = block.timestamp; // Update timestamp
            taxManBuyAmount = 0; // Reset amount to beat
        }

        try dividendTracker.setBalance(from, balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(to, balanceOf(to)) {} catch {}
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 toSwapForLiq = ((tokens * sellTaxes.liquidity) / totalSellTax) / 2;
        uint256 tokensToAddLiquidityWith = ((tokens * sellTaxes.liquidity) / totalSellTax) / 2;
        uint256 toSwapForDev = (tokens * sellTaxes.dev) / totalSellTax;
        uint256 toSwapForTaxMan = (tokens * sellTaxes.taxMan) / totalSellTax;
        uint256 toSwapForTaxKing = (tokens * sellTaxes.taxKing) / totalSellTax;

        // Calculate total tokens to swap for ETH
        uint256 totalTokensToSwap = toSwapForLiq + toSwapForDev + toSwapForTaxMan + toSwapForTaxKing;
        swapTokensForETH(totalTokensToSwap);

        uint256 currentBalance = address(this).balance;

        // Calculate ETH amounts for liquidity, dev, taxMan, and taxKing
        uint256 liqETH = (currentBalance * toSwapForLiq) / totalTokensToSwap;
        uint256 devETH = (currentBalance * toSwapForDev) / totalTokensToSwap;
        uint256 taxManETH = (currentBalance * toSwapForTaxMan) / totalTokensToSwap;
        uint256 taxKingETH = (currentBalance * toSwapForTaxKing) / totalTokensToSwap;

        // Add liquidity
        if (liqETH > 0) {
            addLiquidity(tokensToAddLiquidityWith, liqETH);
        }

        // Send ETH to dev
        if (devETH > 0) {
            (bool successDev, ) = payable(devWallet).call{value: devETH}("");
            require(successDev, "Failed to send ETH to dev wallet");
        }

        // Send ETH to taxMan
        if (taxManETH > 0) {
            (bool successTaxMan, ) = payable(taxMan).call{value: taxManETH}("");
            require(successTaxMan, "Failed to send ETH to taxMan");
        }

        // Send ETH to taxKing
        if (taxKingETH > 0) {
            (bool successTaxKing, ) = payable(taxKing).call{value: taxKingETH}("");
            require(successTaxKing, "Failed to send ETH to taxKing");
        }

        uint256 lpBalance = IERC20(pair).balanceOf(address(this));
        uint256 dividends = lpBalance;

        if (dividends > 0) {
            bool success = IERC20(pair).transfer(address(dividendTracker), dividends);
            if (success) {
                dividendTracker.distributeLPDividends(dividends);
                emit SendDividends(tokens, dividends);
            }
        }
    }

    function ManualLiquidityDistribution(uint256 amount) public onlyOwner {
        bool success = IERC20(pair).transferFrom(msg.sender, address(dividendTracker), amount);
        if (success) {
            dividendTracker.distributeLPDividends(amount);
        }
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(router), tokenAmount);

        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }
}

contract QWEBDividendTracker is Ownable, DividendPayingToken {
    struct AccountInfo {
        address account;
        uint256 withdrawableDividends;
        uint256 totalDividends;
        uint256 lastClaimTime;
    }

    mapping(address => bool) public excludedFromDividends;

    mapping(address => uint256) public lastClaimTimes;

    event ExcludeFromDividends(address indexed account, bool value);
    event Claim(address indexed account, uint256 amount);

    constructor()
        DividendPayingToken("QWEB Dividend Token", "QWEBDT")
    {}

    function trackerRescueETH20Tokens(address recipient, address tokenAddress) external onlyOwner {
        IERC20(tokenAddress).transfer(recipient, IERC20(tokenAddress).balanceOf(address(this)));
    }

    function updateLP_Token(address _lpToken) external onlyOwner {
        LP_Token = _lpToken;
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "QWEB Dividend Tracker: No transfers allowed");
    }

    function excludeFromDividends(address account, bool value) external onlyOwner {
        require(excludedFromDividends[account] != value);
        excludedFromDividends[account] = value;
        if (value == true) {
            _setBalance(account, 0);
        } else {
            _setBalance(account, balanceOf(account));
        }
        emit ExcludeFromDividends(account, value);
    }

    function getAccount(address account) public view returns (address, uint256, uint256, uint256, uint256) {
        AccountInfo memory info;
        info.account = account;
        info.withdrawableDividends = withdrawableDividendOf(account);
        info.totalDividends = accumulativeDividendOf(account);
        info.lastClaimTime = lastClaimTimes[account];
        return (
            info.account,
            info.withdrawableDividends,
            info.totalDividends,
            info.lastClaimTime,
            totalDividendsWithdrawn
        );
    }

    function setBalance(address account, uint256 newBalance) external onlyOwner {
        if (excludedFromDividends[account]) {
            return;
        }
        _setBalance(account, newBalance);
    }

    function processAccount(address payable account) external onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount);
            return true;
        }
        return false;
    }
}