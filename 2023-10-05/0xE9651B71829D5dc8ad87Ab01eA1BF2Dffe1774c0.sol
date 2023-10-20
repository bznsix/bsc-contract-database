/*
Pump it
*/

/*
Tokenomics of Hallodri:
-> Total Supply: 1000000000
-> Team Wallet: 0 (0 %)
-> Max Transaction Amount: 20000000 (2 %)
-> Max Wallet Amount: 20000000 (2 %)
-> Initial Buy Tax: 7 %
-> Initial Sell Tax: 3 %

*/


pragma solidity >= 0.8.19;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;

    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
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

abstract contract Ownable {
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller must be owner");
        _;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;
    }
}

contract Hallodri is Ownable, IERC20 {

    IUniswapV2Router02 public constant UNISWAP_ROUTER = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public UNISWAP_PAIR;

    address private constant BURN_WALLET = 0x000000000000000000000000000000000000dEaD;
    address private constant DEVBUTLER_FEE_RECIPIENT = 0xa55dc4860EE12BAA7dDe8043708B582a4eeBe617;

    uint8 private constant DEVBUTLER_BUYFEE = 5; // = 0.5 %
    uint8 private constant DEVBUTLER_SELLFEE = 5; // = 0.5 %
    uint8 private constant FEE_TRANSFER_INTERVAL = 2;
    uint8 private constant FAIR_EXIT_OWNER_REFUND_PERCENTAGE = 101;
    uint16 private constant HOLDER_SHARE_THRESHOLD = 10000;

    string constant private NAME = "Hallodri";
    string constant private SYMBOL = "HAL";
    uint8 constant private DECIMALS = 18;
    uint256 constant private TOTAL_SUPPLY = 1000000000 * (10 ** DECIMALS);
    uint256 constant private TEAM_SUPPLY = 0 * (10 ** DECIMALS);
    uint256 constant private MAX_TRANSACTION_AMOUNT = 20000000 * (10 ** DECIMALS);
    uint256 constant private MAX_WALLET = 20000000 * (10 ** DECIMALS);
    address private OWNER_FEE_RECIPIENT = 0x2A9983E0c0C1E1A61ed30Ed793e4Ad6fb738b6F3;
    uint8 private OWNER_BUYFEE = 70;
    uint8 private OWNER_SELLFEE = 30;
    bool constant private AUTO_CASHOUT = false;

    bool private launched = false;
    bool private ownerLeft = false;
    bool private fairExiting = false;
    bool private feesPaying = false;

    uint256 private initialLiquidityInETH;
    uint256 private initialMintedLiquidityPoolTokens;
    uint256 private ownerFeesAsTokens;
    uint256 private totalOwnerEarnings;
    uint256 private buyTrades;
    uint256 private sellTrades;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private excludedFromFees;
    mapping(address => bool) private excludedFromMaxTransaction;

    constructor() payable {
        address OWNER = 0x2A9983E0c0C1E1A61ed30Ed793e4Ad6fb738b6F3;
        
        _balances[address(this)] = TOTAL_SUPPLY - TEAM_SUPPLY;
        emit Transfer(address(0), address(this), _balances[address(this)]);
        _balances[OWNER] = TEAM_SUPPLY;
        emit Transfer(address(0), OWNER, _balances[OWNER]);

        excludedFromFees[DEVBUTLER_FEE_RECIPIENT] = true;
        excludedFromFees[OWNER_FEE_RECIPIENT] = true;
        excludedFromFees[BURN_WALLET] = true;
        excludedFromFees[OWNER] = true;
        excludedFromFees[address(this)] = true;

        excludedFromMaxTransaction[DEVBUTLER_FEE_RECIPIENT] = true;
        excludedFromMaxTransaction[OWNER_FEE_RECIPIENT] = true;
        excludedFromMaxTransaction[OWNER] = true;
        excludedFromMaxTransaction[address(this)] = true;
        excludedFromMaxTransaction[address(UNISWAP_ROUTER)] = true;

        transferOwnership(OWNER);
    }

    receive() external payable {}

    function name() public view virtual returns (string memory) {
        return NAME;
    }

    function symbol() public view virtual returns (string memory) {
        return SYMBOL;
    }

    function decimals() public view virtual returns (uint8) {
        return DECIMALS;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return TOTAL_SUPPLY;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 totalFees = 0;
        bool takeFees = launched && !fairExiting && !feesPaying && !excludedFromFees[sender] && !excludedFromFees[recipient];
        if (UNISWAP_PAIR == sender) {
            if (!excludedFromMaxTransaction[recipient]) {
                require(amount <= MAX_TRANSACTION_AMOUNT, "Buy transfer amount exceeds MAX TX");
                require(amount + balanceOf(recipient) <= MAX_WALLET, "Buy transfer amount exceeds MAX WALLET");
                buyTrades = buyTrades + 1;
            }
            if (takeFees) {
                totalFees = ((OWNER_BUYFEE) * amount) / 1000;
                ownerFeesAsTokens = ownerFeesAsTokens + totalFees;
                totalFees = totalFees + (((DEVBUTLER_BUYFEE) * amount) / 1000);
                amount = amount - totalFees;
            }
        } else if (UNISWAP_PAIR == recipient) {
            if (!excludedFromMaxTransaction[sender]) {
                require(amount <= MAX_TRANSACTION_AMOUNT, "Sell transfer amount exceeds MAX TX");
                sellTrades = sellTrades + 1;
                if (AUTO_CASHOUT && sellTrades % FEE_TRANSFER_INTERVAL == 0) {
                    withdrawOrBurnFeeTokens();
                }
            }
            if (takeFees) {
                totalFees = ((OWNER_SELLFEE) * amount) / 1000;
                ownerFeesAsTokens = ownerFeesAsTokens + totalFees;
                totalFees = totalFees + (((DEVBUTLER_SELLFEE) * amount) / 1000);
                amount = amount - totalFees;
            }
        }

        if (totalFees > 0) {
            unchecked {
                _balances[sender] = _balances[sender] - totalFees;
                _balances[address(this)] = _balances[address(this)] + totalFees;
            }
            emit Transfer(sender, address(this), totalFees);
        }

        unchecked {
            _balances[sender] = _balances[sender] - amount;
            _balances[recipient] = _balances[recipient] + amount;
        }

        emit Transfer(sender, recipient, amount);

        if (launched && !fairExiting && !ownerLeft && IERC20(UNISWAP_PAIR).balanceOf(address(this)) != initialMintedLiquidityPoolTokens) {
            revert("You cannot touch liquidity. Call fairExit() to get funds back");
        }

    }

    function manualCashout() public onlyOwner {
        withdrawOrBurnFeeTokens();
    }

    function withdrawOrBurnFeeTokens() internal {
        if (!feesPaying) {
            feesPaying = true;
            uint256 totalFees = _balances[address(this)];
            if (totalFees > 0) {
                if (OWNER_FEE_RECIPIENT == BURN_WALLET && ownerFeesAsTokens > 0) {
                    _transfer(address(this), BURN_WALLET, ownerFeesAsTokens);
                    totalFees = totalFees - ownerFeesAsTokens;
                    ownerFeesAsTokens = 0;
                }
                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = UNISWAP_ROUTER.WETH();
                UNISWAP_ROUTER.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    totalFees,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
                uint256 ownerETHShare = ownerFeesAsTokens == 0 ? 0 : calculateETHShare(ownerFeesAsTokens, totalFees, address(this).balance);
                uint256 devButlerETHShare = address(this).balance - ownerETHShare;
                if (ownerETHShare != 0) {
                    payable(OWNER_FEE_RECIPIENT).transfer(ownerETHShare);
                    totalOwnerEarnings = totalOwnerEarnings + ownerETHShare;
                    ownerFeesAsTokens = 0;
                }
                payable(DEVBUTLER_FEE_RECIPIENT).transfer(devButlerETHShare);
            }
            feesPaying = false;
        }
    }

    function getOwnerFeeTokens() public view virtual returns (uint256) {
        return ownerFeesAsTokens;
    }

    function getTotalOwnerEarnings() public view virtual returns (uint256) {
        return totalOwnerEarnings;
    }

    function sellCount() public view virtual returns (uint256) {
        return sellTrades;
    }

    function buyCount() public view virtual returns (uint256) {
        return buyTrades;
    }

    function getFees() public view virtual returns (uint8, uint8) {
        return (OWNER_BUYFEE / 10, OWNER_SELLFEE / 10);
    }

    function getFeeRecipient() public view virtual returns (address) {
        return OWNER_FEE_RECIPIENT;
    }

    function setFeeRecipient(address newFeeRecipient) public onlyOwner {
        OWNER_FEE_RECIPIENT = newFeeRecipient;
    }

    function setFees(uint8 newBuyFee, uint8 newSellFee) public onlyOwner {
        require(newBuyFee <= 20, "Buy Fee cannot be more than 20%");
        require(newSellFee <= 20, "Sell Fee cannot be more than 20%");
        OWNER_BUYFEE = newBuyFee * 10;
        OWNER_SELLFEE = newSellFee * 10;
    }

    function calculateETHShare(uint256 holderBalance, uint256 totalBalance, uint256 remainingETH) internal pure returns (uint256) {
        return (remainingETH * ((holderBalance * HOLDER_SHARE_THRESHOLD) / totalBalance)) / HOLDER_SHARE_THRESHOLD;
    }

    function openTrading() external onlyOwner payable  {
        require(!launched, "Already launched");
        UNISWAP_PAIR = IUniswapV2Factory(UNISWAP_ROUTER.factory()).createPair(address(this), UNISWAP_ROUTER.WETH());
        excludedFromMaxTransaction[UNISWAP_PAIR] = true;
        _approve(address(this), address(UNISWAP_ROUTER), type(uint256).max);
        (, uint256 amountETH, uint256 liquidity) = UNISWAP_ROUTER.addLiquidityETH{value: msg.value}(
            address(this),
            _balances[address(this)],
            0,
            0,
            address(this),
            block.timestamp
        );
        initialLiquidityInETH = amountETH;
        initialMintedLiquidityPoolTokens = liquidity;
        launched = true;
    }

    function fairExit() external onlyOwner {
        require(launched, "Not even launched");
        require(!ownerLeft, "Owner already left");
        withdrawOrBurnFeeTokens();
        fairExiting = true;
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(UNISWAP_PAIR).getReserves();
        uint256 lpTokensToRemove = calculateETHShare((FAIR_EXIT_OWNER_REFUND_PERCENTAGE * initialLiquidityInETH / 100), 
            (IUniswapV2Pair(UNISWAP_PAIR).token0() == address(this) ? reserve1 : reserve0), initialMintedLiquidityPoolTokens);
        IERC20(UNISWAP_PAIR).approve(address(UNISWAP_ROUTER), type(uint256).max);
        UNISWAP_ROUTER.removeLiquidityETH(
            address(this),
            lpTokensToRemove > initialMintedLiquidityPoolTokens ? initialMintedLiquidityPoolTokens : lpTokensToRemove,
            0,
            0,
            address(this),
            block.timestamp
        );
        payable(getOwner()).transfer(address(this).balance);
        _transfer(address(this), BURN_WALLET, _balances[address(this)]);
        setFees(0, 0);
        renounceOwnership();
        ownerLeft = true;
        fairExiting = false;
    }

}