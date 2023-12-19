// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

//NFT Contract interface
interface NftInterface {
    // function definition of the method we want to interact with
    function mint(uint256 _level, address _recipient) external payable;

    //Get price of level
    function price() external view returns (uint256);

    // function check is Authorized Access to level
    function walletisAuthorized(
        address _wallet,
        uint256 _level
    ) external view returns (bool);
}

//Oracle interface
interface OracleInterface {
    // function definition of the method we want to interact with
    function getLatestPrice(
        uint256 _tokenAmount,
        bool _isBNB
    ) external view returns (uint256);
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function WBNB() external pure returns (address);

    function WAVAX() external pure returns (address);

    function WHT() external pure returns (address);

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

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function addLiquidityBNB(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function addLiquidityAVAX(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function addLiquidityHT(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForAVAXSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForHTSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract CryptoBattle {
    using SafeMath for uint256;

    struct Tower {
        uint256 crystals;
        uint256 money;
        uint256 money2;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256 refs;
        uint256 refDeps;
        uint8 treasury;
        uint8[5] chefs;
    }

    struct KingUser {
        uint256 investments;
        uint256 profit;
    }

    mapping(address => Tower) public towers;
    mapping(address => KingUser) public kinguser;

    uint256 public startDate;
    NftInterface public NFTContract =
        NftInterface(0xB48CD2af963d5e2a211beBFf6D98d419b32Aa30C);
    IERC20 public CBT = IERC20(0x695e8c4e49718EbF665E916e575b00330D49Ae00);
    OracleInterface public Oracle =
        OracleInterface(0x695e8c4e49718EbF665E916e575b00330D49Ae00);
    IUniswapV2Router02 public swapV2Router =
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address public WRAPPED_NATIVE = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    uint256 public BUY_PRICE = 5e14; // 0.0005 BNB
    uint256 public SELL_PRICE = 5e12; // 0.000005 BNB

    uint256 public constant PENALTY_CRYSTAL_SELL = 200; // 20% of penalty trade crystals direct
    uint256 public constant PENALTY_COINS_BURN = 500; // 50% of penalty coins burn

    address payable public WALLET_PROJECT;
    address payable public WALLET_MARKETING;
    address payable public WALLET_FUND;
    address payable public WALLET_TREASURY;
    address payable public WALLET_PARTNER;

    uint256 public constant PROJECT_FEE = 30; // 3% of deposit
    uint256 public constant MARKETING_FEE = 30; // 3% of deposit
    uint256 public constant FUND_FEE = 15; // 1.5% of deposit
    uint256 public constant TREASURY_FEE = 40; // 4% of deposit
    uint256 public constant PARTNER_FEE = 5; // 0.5% of deposit

    uint256 internal constant FEE_C = 15; // SUPPORT fee 1.5% of crystals

    uint256 public constant PERCENTS_DIVIDER = 1000;

    uint256 public constant TIME_STEP = 1 hours; // 3600 seconds

    uint256 public totalChefs;
    uint256 public totalTowers;
    uint256 public totalInvested;

    uint256 public immutable denominator = 10;
    bool public init;

    modifier initialized() {
        require(init, "Not initialized");
        _;
    }

    event FeePayed(address indexed user, uint256 totalAmount);

    constructor(
        address payable _walletMarketing,
        address payable _walletFund,
        address payable _walletTreasury,
        address payable _walletPartner,
        uint256 startTime
    ) {
        require(
            _walletMarketing != address(0) &&
                _walletFund != address(0) &&
                _walletTreasury != address(0) &&
                _walletPartner != address(0)
        );

        WALLET_PROJECT = payable(msg.sender);
        WALLET_MARKETING = _walletMarketing;
        WALLET_FUND = _walletFund;
        WALLET_TREASURY = _walletTreasury;
        WALLET_PARTNER = _walletPartner;

        if (startTime > 0) {
            startDate = startTime;
        } else {
            startDate = block.timestamp;
        }
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function initializeAuto() internal {
        require(!init);
        init = true;
    }

    function UpdateStartDate(uint256 _startDate) public {
        require(
            msg.sender == WALLET_PROJECT,
            "Only developer can update start date"
        );
        require(block.timestamp < startDate, "Start date must be in future");
        require(!init);
        startDate = _startDate;
    }

    function updateMarketingWallet(address newWallet) public {
        require(
            msg.sender == WALLET_PROJECT,
            "Only developer can update start date"
        );
        require(!isContract(newWallet), "New wallet is a contract");
        require(newWallet != address(0), "Invalid address");
        WALLET_MARKETING = payable(newWallet);
    }

    function updateProjectWallet(address newWallet) public {
        require(
            msg.sender == WALLET_PROJECT,
            "Only developer can update start date"
        );
        require(!isContract(newWallet), "New wallet is a contract");
        require(newWallet != address(0), "Invalid address");
        WALLET_PROJECT = payable(newWallet);
    }

    function updateFundWallet(address newWallet) public {
        require(
            msg.sender == WALLET_PROJECT || msg.sender == WALLET_FUND,
            "Only developer can update start date"
        );
        require(!isContract(newWallet), "New wallet is a contract");
        require(newWallet != address(0), "Invalid address");
        WALLET_FUND = payable(newWallet);
    }

    function updatePartnerWallet(address newWallet) public {
        require(
            msg.sender == WALLET_PROJECT || msg.sender == WALLET_PARTNER,
            "Only developer can update start date"
        );
        require(!isContract(newWallet), "New wallet is a contract");
        require(newWallet != address(0), "Invalid address");
        WALLET_PARTNER = payable(newWallet);
    }

    function updateTreasuryWallet(address newWallet) public {
        require(
            msg.sender == WALLET_PROJECT || msg.sender == WALLET_TREASURY,
            "Only developer can update start date"
        );
        require(!isContract(newWallet), "New wallet is a contract");
        require(newWallet != address(0), "Invalid address");
        WALLET_TREASURY = payable(newWallet);
    }

    function FeePayout(uint256 msgValue, uint256 crystl) internal {
        uint256 totalFee = PROJECT_FEE
            .add(MARKETING_FEE)
            .add(FUND_FEE)
            .add(TREASURY_FEE)
            .add(PARTNER_FEE);
        uint256 tokensSwap = msgValue.mul(totalFee).div(PERCENTS_DIVIDER);

        swapTokensForEth(tokensSwap);

        uint256 nativeBalance = address(this).balance;
        if (nativeBalance > 0) {
            uint256 pFee = nativeBalance.mul(PROJECT_FEE).div(totalFee);
            uint256 mFee = nativeBalance.mul(MARKETING_FEE).div(totalFee);
            uint256 fFee = nativeBalance.mul(FUND_FEE).div(totalFee);
            uint256 tFee = nativeBalance.mul(TREASURY_FEE).div(totalFee);
            uint256 pAFee = nativeBalance.mul(PARTNER_FEE).div(totalFee);

            WALLET_PROJECT.transfer(pFee);
            WALLET_MARKETING.transfer(mFee);
            WALLET_FUND.transfer(fFee);
            WALLET_TREASURY.transfer(tFee);
            WALLET_PARTNER.transfer(pAFee);
        }

        uint256 sCFee = crystl.mul(FEE_C).div(PERCENTS_DIVIDER);

        towers[WALLET_PROJECT].crystals += sCFee;
        towers[WALLET_FUND].crystals += sCFee;
        towers[WALLET_MARKETING].crystals += sCFee;
        towers[WALLET_TREASURY].crystals += sCFee;
        towers[WALLET_PARTNER].crystals += sCFee;

        emit FeePayed(msg.sender, tokensSwap);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> WHT
        address[] memory path = new address[](2);
        path[0] = address(CBT);
        path[1] = WRAPPED_NATIVE;

        CBT.approve(address(swapV2Router), tokenAmount);

        // make the swap
        try
            swapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // accept any amount of ETH
                path,
                address(this),
                block.timestamp
            )
        {} catch (bytes memory) {
            try
                swapV2Router.swapExactTokensForBNBSupportingFeeOnTransferTokens(
                    tokenAmount,
                    0, // accept any amount of ETH
                    path,
                    address(this),
                    block.timestamp
                )
            {} catch (bytes memory) {
                try
                    swapV2Router
                        .swapExactTokensForAVAXSupportingFeeOnTransferTokens(
                            tokenAmount,
                            0, // accept any amount of ETH
                            path,
                            address(this),
                            block.timestamp
                        )
                {} catch (bytes memory) {
                    try
                        swapV2Router
                            .swapExactTokensForHTSupportingFeeOnTransferTokens(
                                tokenAmount,
                                0, // accept any amount of ETH
                                path,
                                address(this),
                                block.timestamp
                            )
                    {} catch (bytes memory) {
                        swapV2Router
                            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                                tokenAmount,
                                0, // accept any amount of ETH
                                path,
                                address(this),
                                block.timestamp
                            );
                    }
                }
            }
        }
    }

    function addCrystals(address ref, uint256 tokenAmount) external {
        require(block.timestamp > startDate, "Contract does not launch yet");

        if (block.timestamp > startDate && !init) {
            initializeAuto();
        }
        require(tokenAmount > 0, "Zero amount");

        uint256 priceinBNB = Oracle.getLatestPrice(tokenAmount, true);
        CBT.transferFrom(msg.sender, address(this), tokenAmount);
        uint256 crystals = priceinBNB / BUY_PRICE;

        require(crystals > 0, "Zero crystals");

        address user = msg.sender;
        require(!isContract(user), "Sender is a contract");
        totalInvested += tokenAmount;
        if (towers[user].timestamp == 0) {
            totalTowers++;
            ref = towers[ref].timestamp == 0 ? WALLET_PROJECT : ref;
            towers[ref].refs++;
            towers[user].ref = ref;
            towers[user].timestamp = block.timestamp;
            towers[user].treasury = 0;
        }
        ref = towers[user].ref;
        towers[ref].crystals += (crystals * 8) / 100;
        towers[ref].money += (crystals * 100 * 4) / 100;
        towers[ref].refDeps += crystals;
        towers[user].crystals += crystals;

        kinguser[ref].investments += (((crystals * 8) / 100) * BUY_PRICE);
        kinguser[ref].investments +=
            (((crystals * 100 * 4) / 100) * SELL_PRICE) /
            2;
        kinguser[user].investments += (crystals * BUY_PRICE);

        FeePayout(tokenAmount, crystals);
    }

    function withdrawMoney(uint256 gold) external initialized {
        address user = msg.sender;
        require(!isContract(user), "Sender is a contract");
        require(gold <= towers[user].money && gold > 0);
        towers[user].money -= gold;

        uint256 amountBNB = gold * SELL_PRICE;

        uint256 capProfit = kinguser[user].investments.mul(2);
        uint256 profit = kinguser[user].profit;

        if (amountBNB > capProfit.sub(profit)) {
            uint256 profitExceded = amountBNB;
            amountBNB = capProfit.sub(profit) > 0 ? capProfit.sub(profit) : 0;
            profitExceded = amountBNB > 0
                ? profitExceded.sub(amountBNB)
                : profitExceded;
            uint256 goldRemaing = profitExceded > SELL_PRICE
                ? profitExceded / SELL_PRICE
                : 0;
            if (goldRemaing > 0) {
                towers[user].money += goldRemaing;
            }
        }

        if (amountBNB > 0) {
            uint256 amount = Oracle.getLatestPrice(amountBNB, false);
            kinguser[user].profit += amountBNB;

            CBT.transfer(
                user,
                CBT.balanceOf(address(this)) < amount
                    ? CBT.balanceOf(address(this))
                    : amount
            );
        }
    }

    function tradeCrystals(uint256 _crystals) external initialized {
        address user = msg.sender;
        require(!isContract(user), "Sender is a contract");
        require(_crystals <= towers[user].crystals && _crystals > 0);
        towers[user].crystals -= _crystals;

        uint256 capProfit = kinguser[user].investments;
        uint256 profit = kinguser[user].profit.div(2);

        uint256 amountInvested = _crystals * BUY_PRICE;
        uint256 excededProfit = capProfit.sub(profit) > 0
            ? capProfit.sub(profit)
            : 0;

        amountInvested = amountInvested > excededProfit
            ? excededProfit
            : amountInvested;
        _crystals = amountInvested > 0 ? amountInvested / BUY_PRICE : 0;
        if (amountInvested > 0) {
            kinguser[user].investments -= amountInvested;
        }

        if (_crystals > 0) {
            uint256 penalty = (_crystals * PENALTY_CRYSTAL_SELL) /
                PERCENTS_DIVIDER;
            uint256 amountBNB = (_crystals - penalty) * BUY_PRICE;
            uint256 amount = Oracle.getLatestPrice(amountBNB, false);

            CBT.transfer(
                user,
                CBT.balanceOf(address(this)) < amount
                    ? CBT.balanceOf(address(this))
                    : amount
            );
        }
    }

    function burnCoins(uint256 _gold) external initialized {
        address user = msg.sender;
        require(!isContract(user), "Sender is a contract");
        require(_gold <= towers[user].money && _gold > 0);
        require(towers[user].refs > 0, "Only for users with refs");
        towers[user].money -= _gold;
        uint256 amountBNB = _gold *
            ((SELL_PRICE * PENALTY_COINS_BURN) / PERCENTS_DIVIDER);
        uint256 amount = Oracle.getLatestPrice(amountBNB, false);

        CBT.transfer(
            address(0),
            CBT.balanceOf(address(this)) < amount
                ? CBT.balanceOf(address(this))
                : amount
        );
    }

    function collectMoney() public {
        address user = msg.sender;
        syncTower(user);
        towers[user].hrs = 0;
        towers[user].money += towers[user].money2;
        towers[user].money2 = 0;
    }

    function upgradeTower(uint256 towerId) public {
        require(towerId < 5, "Max 5 towers");
        require(
            NFTContract.walletisAuthorized(msg.sender, towerId),
            "Not authorized"
        );
        address user = msg.sender;
        syncTower(user);
        towers[user].chefs[towerId]++;
        totalChefs++;
        uint256 chefs = towers[user].chefs[towerId];
        towers[user].crystals -= getUpgradePrice(towerId, chefs) / denominator;
        towers[user].yield += getYield(towerId, chefs);
    }

    function getNFTUpgrade(uint256 towerId) external payable {
        require(towerId < 5, "Max 5 towers");
        require(
            NFTContract.walletisAuthorized(msg.sender, towerId) != true,
            "Already Authorized"
        );
        require(msg.value >= NFTContract.price(), "Not enough money");

        NFTContract.mint{value: msg.value}(towerId, msg.sender);

        upgradeTower(towerId);
    }

    function upgradeTreasury() external {
        address user = msg.sender;
        uint8 treasuryId = towers[user].treasury + 1;
        syncTower(user);
        require(treasuryId < 5, "Max 5 treasury");
        (uint256 price, ) = getTreasure(treasuryId);
        towers[user].crystals -= price / denominator;
        towers[user].treasury = treasuryId;
    }

    function sellTower() external {
        collectMoney();
        address user = msg.sender;
        uint8[5] memory chefs = towers[user].chefs;
        totalChefs -= chefs[0] + chefs[1] + chefs[2] + chefs[3] + chefs[4];
        towers[user].money += towers[user].yield * 24 * 5;
        towers[user].chefs = [0, 0, 0, 0, 0];
        towers[user].yield = 0;
        towers[user].treasury = 0;
    }

    function getChefs(address addr) external view returns (uint8[5] memory) {
        return towers[addr].chefs;
    }

    function syncTower(address user) internal {
        require(towers[user].timestamp > 0, "User is not registered");
        if (towers[user].yield > 0) {
            (, uint256 treasury) = getTreasure(towers[user].treasury);
            uint256 hrs = block.timestamp /
                TIME_STEP -
                towers[user].timestamp /
                TIME_STEP;
            if (hrs + towers[user].hrs > treasury) {
                hrs = treasury - towers[user].hrs;
            }
            towers[user].money2 += hrs * towers[user].yield;
            towers[user].hrs += hrs;
        }
        towers[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(
        uint256 towerId,
        uint256 chefId
    ) internal pure returns (uint256) {
        if (chefId == 1) return [500, 5000, 15000, 30000, 50000][towerId];
        if (chefId == 2) return [750, 7500, 22500, 45000, 75000][towerId];
        if (chefId == 3) return [1120, 11200, 33750, 67500, 112500][towerId];
        if (chefId == 4) return [1700, 17000, 51000, 102000, 170000][towerId];
        if (chefId == 5) return [2550, 25500, 76500, 153000, 255000][towerId];
        if (chefId == 6) return [3820, 38200, 114700, 229500, 382500][towerId];
        revert("Incorrect chefId");
    }

    function getYield(
        uint256 towerId,
        uint256 chefId
    ) internal pure returns (uint256) {
        if (chefId == 1) return [4, 56, 179, 382, 678][towerId];
        if (chefId == 2) return [8, 85, 272, 581, 1030][towerId];
        if (chefId == 3) return [12, 128, 413, 882, 1564][towerId];
        if (chefId == 4) return [18, 195, 628, 1340, 2379][towerId];
        if (chefId == 5) return [28, 297, 954, 2035, 3620][towerId];
        if (chefId == 6) return [42, 450, 1439, 3076, 5506][towerId];
        revert("Incorrect chefId");
    }

    function getTreasure(
        uint256 treasureId
    ) internal pure returns (uint256, uint256) {
        if (treasureId == 0) return (0, 24); // price | value
        if (treasureId == 1) return (2400, 30);
        if (treasureId == 2) return (3000, 36);
        if (treasureId == 3) return (3600, 42);
        if (treasureId == 4) return (5000, 48);
        revert("Incorrect treasureId");
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }
}

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
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

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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