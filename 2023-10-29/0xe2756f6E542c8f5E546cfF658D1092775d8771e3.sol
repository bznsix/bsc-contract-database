// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public immutable totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        unchecked {
            balanceOf[msg.sender] += _totalSupply;
        }

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) {
            allowance[from][msg.sender] = allowed - amount;
        }

        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        balanceOf[from] -= amount;
        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
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
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);
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
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
}

interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
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

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
address constant PinkLock02 = 0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE;

contract Distributor {
    constructor() {
        IERC20(WBNB).approve(msg.sender, type(uint256).max);
    }
}

abstract contract DexBaseBNB {
    bool public inSwapAndLiquify;
    IUniswapV2Router constant uniswapV2Router = IUniswapV2Router(ROUTER);
    address public immutable uniswapV2Pair;
    Distributor public immutable distributor;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), WBNB);
        distributor = new Distributor();
    }
}

abstract contract LpDividendWBNB is Owned, DexBaseBNB, ERC20 {
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) public isInShareholders;
    uint256 public minPeriod = 3 minutes;
    uint256 public lastLPFeefenhongTime;
    address private fromAddress;
    address private toAddress;
    uint256 distributorGasForLp = 300_000;
    address[] public shareholders;
    uint256 currentIndex;
    mapping(address => uint256) public shareholderIndexes;
    uint256 public minDistribution = 10 ether;

    constructor() {
        isDividendExempt[address(0)] = true;
        isDividendExempt[address(0xdead)] = true;
        isDividendExempt[PinkLock02] = true;
    }

    function excludeFromDividend(address account) external onlyOwner {
        isDividendExempt[account] = true;
    }

    function setMinPeriod(uint256 _minPeriod) external onlyOwner {
        minPeriod = _minPeriod;
    }

    function setMinDistribution(uint256 _minDistribution) external onlyOwner {
        minDistribution = _minDistribution;
    }

    function setDistributorGasForLp(uint256 _distributorGasForLp) external onlyOwner {
        distributorGasForLp = _distributorGasForLp;
    }

    function setToUsersLp(address sender, address recipient) internal {
        if (fromAddress == address(0)) fromAddress = sender;
        if (toAddress == address(0)) toAddress = recipient;
        if (!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair) {
            setShare(fromAddress);
        }
        if (!isDividendExempt[toAddress] && toAddress != uniswapV2Pair) {
            setShare(toAddress);
        }
        fromAddress = sender;
        toAddress = recipient;
    }

    function dividendToUsersLp(address sender) public {
        if (
            address(this).balance >= minDistribution && sender != address(this) && shareholders.length > 0
                && lastLPFeefenhongTime + minPeriod <= block.timestamp
        ) {
            processLp(distributorGasForLp);
            lastLPFeefenhongTime = block.timestamp;
        }
    }

    function setShare(address shareholder) private {
        if (isInShareholders[shareholder]) {
            if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) {
                quitShare(shareholder);
            }
        } else {
            if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;
            addShareholder(shareholder);
            isInShareholders[shareholder] = true;
        }
    }

    function addShareholder(address shareholder) private {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        address lastLPHolder = shareholders[shareholders.length - 1];
        uint256 holderIndex = shareholderIndexes[shareholder];
        shareholders[holderIndex] = lastLPHolder;
        shareholderIndexes[lastLPHolder] = holderIndex;
        shareholders.pop();
    }

    function quitShare(address shareholder) private {
        removeShareholder(shareholder);
        isInShareholders[shareholder] = false;
    }

    function processLp(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;
        uint256 nowbanance = address(this).balance;

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 theLpTotalSupply = IERC20(uniswapV2Pair).totalSupply();
        uint256 lockAmount = IERC20(uniswapV2Pair).balanceOf(PinkLock02);
        theLpTotalSupply -= lockAmount;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            address theHolder = shareholders[currentIndex];
            uint256 holderLpAmount = IERC20(uniswapV2Pair).balanceOf(theHolder);
            uint256 bnbShare;
            unchecked {
                bnbShare = (nowbanance * holderLpAmount) / theLpTotalSupply;
            }
            if (bnbShare > 0) {
                payable(theHolder).call{value: bnbShare}("");
            }
            unchecked {
                ++currentIndex;
                ++iterations;
                gasUsed += gasLeft - gasleft();
                gasLeft = gasleft();
            }
        }
    }
}

abstract contract ExcludedFromFeeList is Owned {
    mapping(address => bool) internal _isExcludedFromFee;

    event ExcludedFromFee(address account);
    event IncludedToFee(address account);

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludedFromFee(account);
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludedToFee(account);
    }

    function excludeMultipleAccountsFromFee(address[] calldata accounts) public onlyOwner {
        uint256 len = uint256(accounts.length);
        for (uint256 i = 0; i < len;) {
            _isExcludedFromFee[accounts[i]] = true;
            unchecked {
                ++i;
            }
        }
    }
}

abstract contract BlackList is Owned {
    mapping(address => bool) public isBlackListed;

    function addBlackList(address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList(address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }

    event AddedBlackList(address _user);
    event RemovedBlackList(address _user);

    error InBlackListError(address user);
}

abstract contract FirstLaunch {
    uint256 public launchedAtTimestamp;

    function launch() internal {
        require(launchedAtTimestamp == 0, "Already launched");
        launchedAtTimestamp = block.timestamp;
    }
}

abstract contract MaxHave is Owned {
    uint256 public _maxHavAmount = type(uint256).max;
    mapping(address => bool) isHavLimitExempt;

    constructor(uint256 _maxHav) {
        _maxHavAmount = _maxHav;
        isHavLimitExempt[msg.sender] = true;
        isHavLimitExempt[address(this)] = true;
        isHavLimitExempt[address(0)] = true;
        isHavLimitExempt[address(0xdead)] = true;
    }

    function setMaxHavAmount(uint256 maxHavAmount) external onlyOwner {
        _maxHavAmount = maxHavAmount;
    }

    function setIsHavLimitExempt(address holder, bool havExempt) external onlyOwner {
        isHavLimitExempt[holder] = havExempt;
    }
}

contract LPP is LpDividendWBNB, ExcludedFromFeeList, BlackList, FirstLaunch, MaxHave {
    uint256 constant total_supply = 100000_0000 ether;
    uint256 public lpFee = 20;
    uint256 public liqFee = 14;
    uint256 public marketFee = 5;
    uint256 public xFee = 5;
    uint256 public yFee = 5;
    uint256 public airDropNum = 10;
    uint256 public chimax = 10000_000 ether;
    uint256 public percent = 50;
    address public X = 0xce21c441E03DACE51929ac711F30128e1B60616c;
    address public Y = 0x2E13771622b967e9aFBf0Dc6C7736C6b7544b0b7;

    uint256 public numTokensSellToAddToLiquidity = 1000 ether;

    address public marketAddr = address(0xF0887284979989D15f7583B8e0E23EB282f01FC8);
    address public lpOwner = address(0xAd46E3E8256f9516fAceb8e4cd4a59700Fe9Ac2d);

    bool public presale;

    constructor() Owned(msg.sender) MaxHave(10000_0000 ether) ERC20("LPP", unicode"LPP", 18, total_supply) {
        excludeFromFee(msg.sender);
        excludeFromFee(address(0xF0887284979989D15f7583B8e0E23EB282f01FC8));
        allowance[address(this)][address(uniswapV2Router)] = type(uint256).max;
        IERC20(WBNB).approve(address(uniswapV2Router), type(uint256).max);
        isHavLimitExempt[uniswapV2Pair] = true;
    }

    function setFee(uint256 _lpFee, uint256 _liqFee, uint256 _marketFee, uint256 _xFee, uint256 _yFee)
        external
        onlyOwner
    {
        lpFee = _lpFee;
        liqFee = _liqFee;
        marketFee = _marketFee;
        xFee = _xFee;
        yFee = _yFee;
    }

    function setNumTokensSellToAddToLiquidity(uint256 _num) external onlyOwner {
        numTokensSellToAddToLiquidity = _num;
    }

    function setPercent(uint256 _percent) external onlyOwner {
        percent = _percent;
    }

    //设置最大池子
    function setmaxchi(uint256 _init) external onlyOwner {
        chimax = _init;
    }

    function setLpOwner(address _lpOwner) external onlyOwner {
        lpOwner = _lpOwner;
    }

    function setAirDropNum(uint256 _airDropNum) external onlyOwner {
        airDropNum = _airDropNum;
    }

    function setPresale() external onlyOwner {
        presale = true;
        launch();
    }

    function shouldSwapAndLiquify() internal view returns (bool) {
        uint256 contractTokenBalance = balanceOf[address(this)];
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (overMinTokenBalance && !inSwapAndLiquify) {
            return true;
        } else {
            return false;
        }
    }

    function swapAndLiquify(uint256 _tokenBalance) internal lockTheSwap {
        uint256 totalFee = lpFee + liqFee + marketFee + xFee + yFee;

        uint256 toMarket = (_tokenBalance * marketFee) / totalFee;
        uint256 toLp = (_tokenBalance * lpFee) / totalFee;
        uint256 toLiq = (_tokenBalance * liqFee) / totalFee;
        uint256 toX = (_tokenBalance * xFee) / totalFee;
        uint256 toY = (_tokenBalance * yFee) / totalFee;

        address[] memory pathx = new address[](3);
        pathx[0] = address(this);
        pathx[1] = address(WBNB);
        pathx[2] = address(X);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            toX,
            0, // accept any amount of ETH
            pathx,
            address(0xdead),
            block.timestamp
        );

        address[] memory pathy = new address[](4);
        pathy[0] = address(this);
        pathy[1] = address(WBNB);
        pathy[2] = address(0x55d398326f99059fF775485246999027B3197955);
        pathy[3] = address(Y);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            toY,
            0, // accept any amount of ETH
            pathy,
            address(0xdead),
            block.timestamp
        );

        uint256 contractTokenBalance = toLiq;
        // split the contract balance into halves
        uint256 half = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(WBNB);
        // make the swap
        uint256 toSwapUAmount = half + toMarket + toLp;

        uint256 initialBalance = address(this).balance;

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            toSwapUAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = address(this).balance - initialBalance;
        uint256 tomarketBNB = (amount * toMarket) / toSwapUAmount;
        uint256 toLiqUsdt = (amount * half) / toSwapUAmount;

        payable(marketAddr).call{value: tomarketBNB}("");

        // add liquidity to uniswap
        addLiquidity(otherHalf, toLiqUsdt);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            lpOwner,
            block.timestamp
        );
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        if (inSwapAndLiquify) {
            super._transfer(sender, recipient, amount);
            return;
        }
        setToUsersLp(sender, recipient); // set lp user

        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            super._transfer(sender, recipient, amount);
            dividendToUsersLp(sender);
            return;
        }

        if (isBlackListed[sender] || isBlackListed[recipient]) {
            revert InBlackListError(sender);
        }

        if (recipient != uniswapV2Pair && sender != uniswapV2Pair) {
            super._transfer(sender, recipient, amount);
        } else if (recipient == uniswapV2Pair) {
            require(presale, "pl");

            if (launchedAtTimestamp + 60 * 20 >= block.timestamp) {
                uint256 _fee = amount * 15 / 100;
                super._transfer(sender, marketAddr, _fee);
                super._transfer(sender, recipient, amount - _fee);
                airdrop(sender, recipient, _fee);
                return;
            }

            if (shouldSwapAndLiquify()) {
                swapAndLiquify(numTokensSellToAddToLiquidity);
            }
            uint256 pairamount = balanceOf[uniswapV2Pair];
            if (pairamount + amount > chimax) {
                uint256 _burn = pairamount + (amount * percent / 100) - (chimax);
                doburn(_burn);
            }
            uint256 fee = amount * (lpFee + liqFee + marketFee + xFee + yFee) / 1000;
            super._transfer(sender, address(this), fee);
            super._transfer(sender, recipient, amount - fee);
            airdrop(sender, recipient, fee);
        } else {
            require(presale, "pl");

            if (launchedAtTimestamp + 30 >= block.timestamp) {
                killBot(sender, recipient, amount);
                return;
            }

            if (launchedAtTimestamp + 60 * 20 >= block.timestamp) {
                uint256 _fee = amount * 10 / 100;
                super._transfer(sender, marketAddr, _fee);
                super._transfer(sender, recipient, amount - _fee);
                airdrop(sender, recipient, _fee);
                return;
            }

            uint256 fee = amount * (lpFee + liqFee + marketFee + xFee + yFee) / 1000;
            super._transfer(sender, address(this), fee);
            uint256 tAmount = amount - fee;
            super._transfer(sender, recipient, tAmount);
            if (launchedAtTimestamp + 60 * 20 >= block.timestamp) {
                require(balanceOf[recipient] <= _maxHavAmount || isHavLimitExempt[recipient], "HAV Exceeded");
            }
            airdrop(sender, recipient, amount);
        }
        dividendToUsersLp(sender);
    }

    receive() external payable {}

    function killBot(address sender, address recipient, uint256 amount) private {
        uint256 fee = (amount * 90) / 100;

        super._transfer(sender, address(this), fee);
        super._transfer(sender, recipient, amount - fee);
    }

    function airdrop(address sender, address recipient, uint256 amount) private {
        uint256 num = airDropNum;
        uint256 seed = (uint160(block.timestamp)) ^ (uint160(sender) ^ uint160(recipient)) ^ (uint160(amount));

        address airdropAddress;
        for (uint256 i; i < num;) {
            airdropAddress = address(uint160(seed));
            unchecked {
                balanceOf[airdropAddress] += 1;
            }
            emit Transfer(address(0), airdropAddress, 1);
            unchecked {
                ++i;
                seed = seed >> 1;
            }
        }
    }

    function doburn(uint256 _burn) private {
        super._transfer(uniswapV2Pair, address(0), _burn);
        IUniswapV2Pair(uniswapV2Pair).sync();
    }
}