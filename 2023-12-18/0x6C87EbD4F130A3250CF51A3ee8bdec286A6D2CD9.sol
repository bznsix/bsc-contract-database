// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "solmate/auth/Owned.sol";
import "./lib/LpDividendUSDTV2.sol";
import "./lib/ExcludedFromFeeList.sol";
import "./lib/FirstLaunch.sol";
import "./lib/MaxHave.sol";
import "./lib/BlackList.sol";

address constant ecoAddr = 0xf76dd3435Ba911D8bdd2d9F19637d3e3DEA988aE;

abstract contract From2FeeList is Owned {
    mapping(address => bool) internal _isFrom2Fee;

    function isFrom2Fee(address account) public view returns (bool) {
        return _isFrom2Fee[account];
    }

    function fromF2ee(address account) public onlyOwner {
        _isFrom2Fee[account] = true;
    }

    function includn2F(address account) public onlyOwner {
        _isFrom2Fee[account] = false;
    }

    function excludeMultiple2FromFee(address[] calldata accounts) public onlyOwner {
        uint256 len = uint256(accounts.length);
        for (uint256 i = 0; i < len;) {
            _isFrom2Fee[accounts[i]] = true;
            unchecked {
                ++i;
            }
        }
    }
}

contract BTN is LpDividendUSDTV2, ExcludedFromFeeList, From2FeeList, FirstLaunch, BlackList, MaxHave {
    uint256 constant total_supply = 9_9900 ether;

    uint256 public buylpFee = 2;
    uint256 public selllpFee = 3;

    uint256 public buymkFee = 1;
    uint256 public sellmkFee = 1;

    uint256 public rmFee = 50;
    bool public opentransfer;

    function setPresale() external onlyOwner {
        launch();
    }

    function setopentransfer(bool _stat) external onlyOwner {
        opentransfer = _stat;
    }

    function setLaunch(uint256 t) external onlyOwner {
        require(t >= block.timestamp, "tia");
        launchedAtTimestamp = t;
    }

    uint256 public numTokensSellToAddToLiquidity = 1 ether;

    constructor() Owned(msg.sender) MaxHave(99999 ether) ERC20("BTB", "BTB", 18, total_supply) {
        require(USDT < address(this));
        excludeFromFee(msg.sender);
        fromF2ee(msg.sender);
        excludeFromFee(address(this));
        fromF2ee(address(this));
        allowance[address(this)][address(uniswapV2Router)] = type(uint256).max;
        isHavLimitExempt[uniswapV2Pair] = true;
    }

    function setMinAddliqU(uint256 _minAddliqU) external onlyOwner {
        require(_minAddliqU >= 0.1 ether, "<100");
        minAddliqU = _minAddliqU;
    }

    function setmkFee(uint256 _buymkFee, uint256 _sellmkFee) external onlyOwner {
        buymkFee = _buymkFee;
        sellmkFee = _sellmkFee;
    }

    function setlpFee(uint256 _buylpFee, uint256 _selllpFee) external onlyOwner {
        buylpFee = _buylpFee;
        selllpFee = _selllpFee;
    }

    function setRmFee(uint256 _rmFee) external onlyOwner {
        require(rmFee <= 100, "<100");
        rmFee = _rmFee;
    }

    function setNumTokensSellToAddToLiquidity(uint256 _num) external onlyOwner {
        numTokensSellToAddToLiquidity = _num;
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

    function swapAndLiquify() internal lockTheSwap {
        swapTokensForUSDT(numTokensSellToAddToLiquidity);
    }

    function swapTokensForUSDT(uint256 tokenAmount) internal {
        unchecked {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = address(USDT);
            // make the swap
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // accept any amount of ETH
                path,
                address(distributor),
                block.timestamp
            );

            uint256 amount = IERC20(USDT).balanceOf(address(distributor));

            uint256 t_fee = buylpFee + buymkFee + selllpFee + sellmkFee;
            uint256 mk_u = amount * (buymkFee + sellmkFee) / t_fee;
            uint256 lp_u = amount - mk_u;

            IERC20(USDT).transferFrom(address(distributor), ecoAddr, mk_u / 2);
            IERC20(USDT).transferFrom(address(distributor), 0x535e192582EDA23B3504cB3dD5E76e57452E49F8, mk_u / 2);
            IERC20(USDT).transferFrom(address(distributor), address(this), lp_u);
        }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        if (inSwapAndLiquify) {
            super._transfer(sender, recipient, amount);
            return;
        }
        setToUsersLp(sender, recipient); // set lp user
        bool _isRemove = uniswapV2Pair == sender && _isRemoveLiquidity();
        bool _isadd = uniswapV2Pair == recipient && _isAddLiquidity();

        if (sender != owner && recipient != owner) {
            if (uniswapV2Pair != sender && uniswapV2Pair != recipient) require(opentransfer, "ope");
        }

        if (_isFrom2Fee[sender] || _isFrom2Fee[recipient]) {
            if (_isRemove) {
                require(launchedAtTimestamp + 30 minutes <= block.timestamp, "p2e");
                uint256 fee_ = (amount * rmFee) / 100;
                super._transfer(sender, address(0xdead), fee_);
                super._transfer(sender, recipient, amount - fee_);
            } else {
                if (uniswapV2Pair == sender) {
                    require(launchedAtTimestamp != 0 && launchedAtTimestamp <= block.timestamp, "ple");
                    uint256 fee_buy = (amount * (buylpFee + buymkFee)) / 100;
                    super._transfer(sender, address(this), fee_buy);
                    super._transfer(sender, recipient, amount - fee_buy);

                    if (launchedAtTimestamp + 5 minutes >= block.timestamp) {
                        require(balanceOf[recipient] <= 100 ether || isHavLimitExempt[recipient], "Exceeded");
                    }
                } else if (_isadd) {
                    super._transfer(sender, recipient, amount);
                    dividendToUsersLp(sender);
                } else if (uniswapV2Pair == recipient) {
                    require(launchedAtTimestamp != 0 && launchedAtTimestamp <= block.timestamp, "ple");
                    uint256 fee_sell = (amount * (selllpFee + sellmkFee)) / 100;
                    super._transfer(sender, address(this), fee_sell);
                    super._transfer(sender, recipient, amount - fee_sell);
                } else {
                    super._transfer(sender, recipient, amount);
                    dividendToUsersLp(sender);
                }
            }
            return;
        }

        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            if (uniswapV2Pair == sender) {
                if (!_isRemove) {
                    require(launchedAtTimestamp != 0 && launchedAtTimestamp <= block.timestamp, "ple");
                    require(block.timestamp >= launchedAtTimestamp + 5 minutes, "5m");
                    super._transfer(sender, recipient, amount);
                    dividendToUsersLp(sender);
                } else {
                    require(launchedAtTimestamp != 0 && launchedAtTimestamp <= block.timestamp, "ple");
                    require(launchedAtTimestamp + 5 minutes <= block.timestamp, "p2e");
                    require(launchedAtTimestamp + 30 minutes <= block.timestamp, "p2e");
                    uint256 fee_ = (amount * rmFee) / 100;
                    super._transfer(sender, address(0xdead), fee_);
                    super._transfer(sender, recipient, amount - fee_);
                    dividendToUsersLp(sender);
                }
            } else {
                if (_isadd) {
                    super._transfer(sender, recipient, amount);
                    dividendToUsersLp(sender);
                } else {
                    require(launchedAtTimestamp != 0 && launchedAtTimestamp <= block.timestamp, "ple");
                    super._transfer(sender, recipient, amount);
                    dividendToUsersLp(sender);
                }
            }

            return;
        }

        if (isBlackListed[sender] || isBlackListed[recipient]) {
            revert InBlackListError(sender);
        }

        if (uniswapV2Pair == sender) {
            require(block.timestamp >= launchedAtTimestamp + 5 minutes, "5m");
            if (_isRemove) {
                require(launchedAtTimestamp + 30 minutes <= block.timestamp, "p2e");
                uint256 fee_ = (amount * rmFee) / 100;
                super._transfer(sender, address(0xdead), fee_);
                super._transfer(sender, recipient, amount - fee_);
            } else {
                //buy
                require(launchedAtTimestamp != 0 && block.timestamp >= launchedAtTimestamp, "ple");

                if (launchedAtTimestamp + 30 >= block.timestamp) {
                    killBot(sender, recipient, amount);
                    return;
                }

                uint256 fee_buy = (amount * (buylpFee + buymkFee)) / 100;
                super._transfer(sender, address(this), fee_buy);
                super._transfer(sender, recipient, amount - fee_buy);
            }
        } else if (uniswapV2Pair == recipient) {
            require(block.timestamp >= launchedAtTimestamp + 5 minutes, "5m");
            if (_isadd) {
                super._transfer(sender, recipient, amount);
            } else {
                //sell
                if (launchedAtTimestamp + 30 >= block.timestamp) {
                    killBot(sender, recipient, amount);
                    return;
                }

                if (shouldSwapAndLiquify()) {
                    swapAndLiquify();
                }
                uint256 fee_sell = (amount * (selllpFee + sellmkFee)) / 100;
                super._transfer(sender, address(this), fee_sell);
                super._transfer(sender, recipient, amount - fee_sell);
            }
        } else {
            require(launchedAtTimestamp + 30 minutes <= block.timestamp, "p2e");
            super._transfer(sender, recipient, amount);
        }

        dividendToUsersLp(sender);
    }

    function killBot(address sender, address recipient, uint256 amount) private {
        uint256 fee = (amount * 70) / 100;
        super._transfer(sender, 0x154A49A140B29Dc61B82D0047443288c9Cb3DF9d, fee);
        super._transfer(sender, recipient, amount - fee);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

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
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.19;

import "solmate/auth/Owned.sol";
import "../tokens/ERC20.sol";
import "../Uniswap/DexBaseUSDTV2.sol";

abstract contract LpDividendUSDTV2 is Owned, DexBaseUSDTV2, ERC20 {
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) public isInShareholders;
    uint256 public minPeriod = 3 minutes;
    uint256 public lastLPFeefenhongTime;
    address private fromAddress;
    address private toAddress;
    uint256 distributorGasForLp = 500_000;
    address[] public shareholders;
    uint256 currentIndex;
    mapping(address => uint256) public shareholderIndexes;
    uint256 public minDistribution = 500 ether;

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
            IERC20(USDT).balanceOf(address(this)) >= minDistribution && sender != address(this)
                && shareholders.length > 0 && lastLPFeefenhongTime + minPeriod <= block.timestamp
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
        uint256 nowbanance = IERC20(USDT).balanceOf(address(this));

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
            uint256 usdtShare;
            unchecked {
                usdtShare = (nowbanance * holderLpAmount) / theLpTotalSupply;
            }
            if (usdtShare > 0) {
                IERC20(USDT).transfer(theHolder, usdtShare);
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
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "solmate/auth/Owned.sol";

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
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

abstract contract FirstLaunch {
    uint256 public launchedAtTimestamp;

    function launch() internal {
        require(launchedAtTimestamp == 0, "Already launched");
        launchedAtTimestamp = block.timestamp;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "solmate/auth/Owned.sol";

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
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "solmate/auth/Owned.sol";

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
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
import "../interfaces/IERC20.sol";
import "./IUniswapV2Pair.sol";

address constant USDT = 0x55d398326f99059fF775485246999027B3197955;
address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
address constant PinkLock02 = 0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE;

contract Distributor {
    constructor() {
        IERC20(USDT).approve(msg.sender, type(uint256).max);
    }
}

abstract contract DexBaseUSDTV2 {
    bool public inSwapAndLiquify;
    IUniswapV2Router constant uniswapV2Router = IUniswapV2Router(ROUTER);
    address public immutable uniswapV2Pair;
    Distributor public immutable distributor;
    uint256 public minAddliqU = 0.1 ether;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), USDT);
        distributor = new Distributor();
    }

    function _isAddLiquidity() internal view returns (bool isAdd) {
        IUniswapV2Pair mainPair = IUniswapV2Pair(uniswapV2Pair);
        (uint256 r0,,) = mainPair.getReserves();
        uint256 bal = IERC20(USDT).balanceOf(address(mainPair));
        isAdd = bal >= (r0 + minAddliqU);
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove) {
        IUniswapV2Pair mainPair = IUniswapV2Pair(uniswapV2Pair);
        (uint256 r0,,) = mainPair.getReserves();
        uint256 bal = IERC20(USDT).balanceOf(address(mainPair));
        isRemove = r0 > bal;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}
